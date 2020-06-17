provider "aws" {
  region = "ap-south-1"
  profile = "default"
}






resource "aws_instance" "instask1" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name 	=  "mykey1"
  security_groups = [ "sgtask1" ]

   connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/AKS/Downloads/mykey1.pem")
    host     = aws_instance.instask1.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install java httpd php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }
  
  tags = {
    Name = "Task1111111os"
  }
}



resource "aws_ebs_volume" "ebstask1" {
  availability_zone = aws_instance.instask1.availability_zone
  size              = 1
  tags = {
    Name = "ebstask1"
  }
}



resource "aws_volume_attachment" "ebstask1attach" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.ebstask1.id
  instance_id = aws_instance.instask1.id
  force_detach = true
}



output "instance_ip" {
	value = aws_instance.instask1.public_ip
}



resource "null_resource" "nulllocal"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.instask1.public_ip} > pubip.txt"
  	}
}



resource "null_resource" "nullremote"  {
 depends_on = [
    aws_volume_attachment.ebstask1attach,
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/AKS/Downloads/mykey1.pem")
    host     = aws_instance.instask1.public_ip
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdd",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*.*",
      "sudo git clone https://github.com/Abhishek2019singh/cloud_task1.git /var/www/html/"
    ]
  }
}



output "ebs_name" {
	value = aws_ebs_volume.ebstask1.id
}





resource "aws_s3_bucket" "buckettask1" {
  bucket = "buckettask1"
  acl    = "public-read"
  tags = {
      Name = "buckettask1"
      Environment = "Developer"
  }
}



output "bucket" {
  value = aws_s3_bucket.buckettask1
}



resource "aws_s3_bucket_object" "buckettask1obj" {
  bucket = aws_s3_bucket.buckettask1.id
  key    = "AKS.jpg"
  source = "C:/Users/AKS/Desktop/terra/test_task/gitcode/AKS.jpg"
  acl	 = "public-read"
}



