require 'aws-sdk'

module Helper
  extend self

  def wait_for_output(output, &block)
    begin
      print "."
      sleep 1
    end while block.call != output
    print "\n"
  end

  def create_table(name, reads, writes)
    dynamo = AWS::DynamoDB.new
    begin
      db = dynamo.tables.create(name, reads, writes, hash_key: { phone_number: :string })
    rescue AWS::DynamoDB::Errors::ResourceInUseException
      puts "database named: #{name} already exists"
    end
  end

  def create_queue(name)
    sqs = AWS::SQS.new
    sqs.queues.create(name)
  end

  def build_image(type, environment)
    ec2 = AWS::EC2.new

    # create security group if it doesn't already exist
    sg = ec2.security_groups.filter('group-name', 'vip-sms-app-imaging').to_a.first
    if sg.nil?
      sg = ec2.security_groups.create('vip-sms-app-imaging')
      sg.authorize_ingress(:tcp, 22, '0.0.0.0/0')
    end

    instance = ec2.instances.create(image_id: "ami-864d84ee",
                                    count: 1,
                                    instance_type: "m3.medium",
                                    key_name: "vip-sms",
                                    security_group_ids: [sg.id])
    instance.add_tag("Name", value: "vip-sms-app-imaging--#{type}")

    puts "Waiting for instance to start"
    wait_for_output(:running) { instance.status }

    begin
      ip = instance.public_ip_address
      sleep 1
    end while ip.nil?

    puts "Sleeping for 60 seconds to wait for everything to become available"
    sleep 60

    system("echo 'default ansible_ssh_host=#{ip}' > machine")
    system("ansible-playbook roles/all.yml --extra-vars \"user=ubuntu type=#{type} env=#{environment}\" -i machine")
    system('rm machine')

    puts "Sleeping for 5 seconds to wait for everything to become available"
    sleep 5

    instance.stop
    puts "Waiting for instance to stop"
    wait_for_output(:stopped) { instance.status }

    image = instance.create_image("vip-sms-app-#{type}-#{environment}-#{Time.now.strftime("%d-%m-%y--%H-%M-%S")}")
    instance.terminate

    puts "Created image: #{image.name} with id: #{image.id}"
  end
end
