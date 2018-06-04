# aws_labs

## create-aws-ami.sh
Automation tool to create enviroment aws ec2 cloud.                        
Allowing to launch several instances ami Free tier eligible.
(Filter 4 lastest Ubuntu linux). Modify to change amiArray

Ami Selection:
1) ami-fe34128d
2) ami-fa9dbf9c
3) ami-f90a4880   
4) ami-f7a28084

Region Selection:
1) ap-south-1	      6) ap-northeast-1     11) eu-central-1
2) eu-west-3	      7) sa-east-1          12) us-east-1
3) eu-west-2        8) ca-central-1       13) us-east-2
4) eu-west-1	      9) ap-southeast-1     14) us-west-1
5) ap-northeast-2   10) ap-southeast-2    15) us-west-2

To this labs the scripts will finish launching:
   1. - stop-instance-xxxxx.sh
   2. - terminate-instance-xxxxx.sh

Note: Comment these lines to working with the tenant created !

Creates:
  - VPC, SUBNET, IGWDEFAULT, SECURITY GROUP, RULE SSH_PORT (22)
  - DNS and DNS Hostname Support
  - In case create 1 instance:
    - start-instanche-<randomNumber>.sh    # start tenant tool
    - stop-instanche-<randomNumber>.sh     # stop tenant tool
    - terminate-instance-<randomNumber>.sh # terminate/delete tenant tool
```
Usage:
       create-aws-ami.sh [options] Wizard show menu to Select Region && Ami
       create-aws-ami.sh --region <region_id> --ami <image_id> [options]


Desc:
      Create enviroment aws ec2 cloud in determinate aws Region.
      Launching several instance Free tier eligible ami.


Note: Filter to 4 lastest Ubuntu in Region Selected.
      To modify Change amisArray filters


Options:
   -h|--help                  Displays this help
   -v|--verbose               Displays verbose output
  -nc|--no-colour             Disables colour output
  -cr|--cron                  Run silently unless we encounter an error
