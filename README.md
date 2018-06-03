# aws_labs

## create-aws-ami.sh
Automation tool to create enviroment aws ec2 cloud.                        
Allowing to launch several instances ami Free tier eligible.
(Filter 4 lastest Ubuntu linux). Modify to change amiArray
Creates:
  - VPC, SUBNET, IGWDEFAULT, SECURITY GROUP, RULE SSH_PORT (22)
  - DNS and DNS Hostname Support
  · In case create 1 instance:
    - start-instanche-<randomNumber>.sh    # start tenant tool
    - stop-instanche-<randomNumber>.sh     # stop tenant tool
    - terminate-instance-<randomNumber>.sh # terminate/delete tenant tool
```
Usage:
       create-aws-ami.sh [options] Wizard show menu to Select Region && Ami
       create-aws-ami.sh --region <region_id> --ami <image_id> [options]```


Desc:
      Create enviroment aws ec2 cloud in determinate aws Region.
      Launching several instance Free tier eligible ami.```


Note: Filter to 4 lastest Ubuntu in Region Selected.
      To modify Change amisArray filters```


Options:
   -h|--help                  Displays this help
   -v|--verbose               Displays verbose output
  -nc|--no-colour             Disables colour output
  -cr|--cron                  Run silently unless we encounter an error
