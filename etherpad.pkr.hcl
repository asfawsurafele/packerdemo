#If you get an error about image-block-public access, do aws ec2 disable-image-block-public-access --region us-west-1'.

#Once 'packer build etherpad.pkr.hcl, you will be given an AMI, the output will look like:

# Builds finished. The artifacts of successful builds are:
# --> awsinaction-etherpad.amazon-ebs.etherpad: AMIs were created:
# us-west-1: ami-0038d25e927e92f41 <--- use that as value for $AMI

#To deploy your customized AMI with packer

# aws cloudformation deploy --stack-name etherpad-packer \
# ➥ --template-file packer.yaml
# ➥ --parameter-overrides AMI=$AMI \
# ➥ --capabilities CAPABILITY_IAM


packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "etherpad" {
  ami_name = "awsinaction-etherpad-{{timestamp}}"
  tags = {
    Name = "awsinaction-etherpad"
  }
  instance_type = "t2.micro"
  region        = "us-west-1"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-2.0.20231116.0-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"]
  }
  ssh_username         = "ec2-user"
  ssh_interface        = "session_manager"
  communicator         = "ssh"
  iam_instance_profile = "ec2-ssm-core"
  ami_groups = ["all"]
  ami_regions = ["us-west-1"]
}

build {
  name    = "awsinaction-etherpad"
  sources = [
    "source.amazon-ebs.etherpad"
  ]
  
  provisioner "shell" {
    inline = [
    "sudo yum install git -y",
    "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash",
    ". ~/.nvm/nvm.sh",
    "nvm install 16.0.0",
    "node -e \"console.log('Running Node.js ' + process.version)\"",
    "sudo mkdir /opt/etherpad-lite",
    "sudo chown -R ec2-user:ec2-user /opt/etherpad-lite",
    "cd /opt",
    "git clone --depth 1 --branch 1.8.17 https://github.com/AWSinAction/etherpad-lite.git",                      
    "cd etherpad-lite",
    "./src/bin/installDeps.sh"
  ]
}
}

