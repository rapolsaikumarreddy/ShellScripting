echo -e "\e[33m ---- |Rapol First AWS Script| ----\033[0m"
echo ""
echo ""


aws_image_id="ami-0080e4c5bc078760e"
aws_instance_type="t2.micro"
aws_subnetId="subnet-04abf7f3e72a7d897"
aws_tag_key="dev_instance"
aws_tag_value="bash_dev_instance"
aws_key_name="rapol_key"
ssh_key="rapol_key.pem"
aws_security_groupId="sg-015c35f3195812390"


echo -e "\e[33m ---- | Generating Keypair for ec2 instance | ----\033[0m"
aws ec2 create-key-pair --key-name rapol_key --query 'KeyMaterial' output text 2>$1 | tee $ssh_key

#Setting permissions for pem file

echo -e "\e[33m ---- |Setting Read only Permissions to pem file| ----\033[0m"
chmod 400 $ssh_key

echo "Creating ec2 instance in AWS"

ec2_instanceId=$(aws ec2 run-instances --image-id $aws_image_id --count 1 --instance-type $aws_instance_type --key-name $aws_key_name --security-group-ids $aws_security_groupId --subnet-id $aws_subnetId --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=$aws_tag_key,Value=$aws_tag_value}]'| grep InstanceId | cut -d":" -f2 | cut -d'"' -f2)
 
#echo $ec2_instanceId
echo "============================="
date >> logs.txt

echo -e "\t\033[0;31mEC2 Instance ID: $ec2_instanceId\033[0m"
echo " "
public_ip=$(aws ec2 describe-instances --instance-ids $ec2_instanceId --query 'Reservations[0].Instances[0].PublicIpAddress' | cut -d'"' -f2)
echo -e "\t\033[0;31mElastic IP: $public_ip\033[0m"
echo $public_ip >> logs.txt
echo "=============================" >> logs.txt

echo " "
count_down=60
echo -e "\e[32m Please wait while your instance is being powered on..We are trying to ssh into the EC2 instance\033[0m"
echo " "
echo -e "\e[32m Copy/paste the below command to acess your EC2 instance via SSH from this machine. You may need this later.\033[0m"
echo " "
echo -e "\033[0;31m         ssh -i $ssh_key ec2-user@$public_ip\033[0m"
echo " "
#temp_count=${count_down}
while [[ $count_down -gt 0 ]]
do 
printf "\rYou have %2d second(s) remaining to hit Ctrl+C to cancel that operation!" ${count_down}
sleep 1
((count_down--))
done
echo " "






ssh -i "$ssh_key" ec2-user@$public_ip
