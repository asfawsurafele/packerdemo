# MAKE SURE YOUR AWS CLI IS CONFIGURED TO US-WEST-1,
```
surafeleasfaw@Surafeles-MacBook-Air packer % aws configure
AWS Access Key ID [********************]: 
AWS Secret Access Key [********************]: 
Default region name [us-west-1]: 
Default output format [json]:
```
###  CREATE DEFAULT VPC IF YOU DONT HAVE ONE IN US-WEST-1
```
aws ec2 create-default-vpc
```

Install packer on local machine, for windows:
```
choco install packer 
```
for Mac:
```
brew install packer
```

Then, run:
```
packer init chapter15/
```
and
```
packer build etherpad.pkr.hcl 
```
in terminal, you will be given an AMI, the output will look like:



```
Builds finished. The artifacts of successful builds are:
--> awsinaction-etherpad.amazon-ebs.etherpad: AMIs were created:
us-west-1: ami-0038d25e927e92f41 <--- use that as value for $AMI
```

If you get an error about image-block-public access, run: 
```
aws ec2 disable-image-block-public-access --region us-west-1'.
```

### To deploy your customized AMI with packer
```
aws cloudformation deploy --stack-name etherpad-packer \
--template-file packer.yaml \
--parameter-overrides AMI=ami-0038d25e927e92f41 \
--capabilities CAPABILITY_IAM
```
Replace the AMI value with the value you receive from the packer build command.

### To delete your stack:
```
aws cloudformation describe-stacks --stack-name etherpad-packer \
➥ --query "Stacks[0].Outputs[0].OutputValue" --output text
```
