#!/bin/bash
# create-aws-ami.sh
# #############################################################################
# Jaime Silva Gonzalez                        v1.00                 29/05/2018
# #############################################################################
# NOTE: A best practices Bash script template with many useful functions.
# A better class of script...
set -o errexit                      # Exit on most errors (see the manual)
set -o errtrace                     # Make sure any error trap is inherited
set -o nounset                      # Disallow expansion of unset variables
set -o pipefail                     # Use last non-zero exit code in a pipeline
#set -o xtrace                      # Trace the execution of the script (debug)


# DESC: Handler for unexpected errors
# ARGS: $1 (optional): Exit code (defaults to 1)
# OUTS: None
function script_trap_err() {
  local exit_code=1

  # Disable the error trap handler to prevent potential recursion
  trap - ERR

  # Consider any further errors non-fatal to ensure we run to completion
  set +o errexit
  set +o pipefail

  # Validate any provided exit code
  if [[ ${1-} =~ ^[0-9]+$ ]]; then
    exit_code="$1"
  fi

  # Output debug data if in Cron mode
  if [[ -n ${cron-} ]]; then
    # Restore original file output descriptors
    if [[ -n ${script_output-} ]]; then
      exec 1>&3 2>&4
    fi

    # Print basic debugging information
    printf '%b\n' "$ta_none"
    printf '***** Abnormal termination of script *****\n'
    printf 'Script Path:            %s\n' "$script_path"
    printf 'Script Parameters:      %s\n' "$script_params"
    printf 'Script Exit Code:       %s\n' "$exit_code"

    # Print the script log if we have it. It's possible we may not if we
    # failed before we even called cron_init(). This can happen if bad
    # parameters were passed to the script so we bailed out very early.
    if [[ -n ${script_output-} ]]; then
      printf 'Script Output:\n\n%s' "$(cat "$script_output")"
    else
      printf 'Script Output:          None (failed before log init)\n'
    fi
  fi

  # Exit with failure status
  exit "$exit_code"
}


# DESC: Handler for exiting the script
# ARGS: None
# OUTS: None
function script_trap_exit() {
  cd "$orig_cwd"

  # Remove Cron mode script log
  if [[ -n ${cron-} && -f ${script_output-} ]]; then
    rm "$script_output"
  fi

  # Restore terminal colours
  printf '%b' "$ta_none"
}


# DESC: Exit script with the given message
# ARGS: $1 (required): Message to print on exit
#       $2 (optional): Exit code (defaults to 0)
# OUTS: None
function script_exit() {
  if [[ $# -eq 1 ]]; then
    printf '%s\n' "$1"
    exit 0
  fi

  if [[ ${2-} =~ ^[0-9]+$ ]]; then
    printf '%b\n' "$1"
    # If we've been provided a non-zero exit code run the error trap
    if [[ $2 -ne 0 ]]; then
      script_trap_err "$2"
    else
      exit 0
    fi
  fi

  script_exit 'Missing required argument to script_exit()!' 2
}


# DESC: Generic script initialisation
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: $orig_cwd: The current working directory when the script was run
#       $script_path: The full path to the script
#       $script_dir: The directory path of the script
#       $script_name: The file name of the script
#       $script_params: The original parameters provided to the script
#       $ta_none: The ANSI control code to reset all text attributes
# NOTE: $script_path only contains the path that was used to call the script
#       and will not resolve any symlinks which may be present in the path.
#       You can use a tool like realpath to obtain the "true" path. The same
#       caveat applies to both the $script_dir and $script_name variables.
function script_init() {
  # Useful paths
  readonly orig_cwd="$PWD"
  readonly script_path="${BASH_SOURCE[0]}"
  readonly script_dir="$(dirname "$script_path")"
  readonly script_name="$(basename "$script_path")"
  readonly script_params="$*"

  # Important to always set as we use it in the exit handler
  readonly ta_none="$(tput sgr0 2> /dev/null || true)"
}


# DESC: Initialise colour variables
# ARGS: None
# OUTS: Read-only variables with ANSI control codes
# NOTE: If --no-colour was set the variables will be empty
function colour_init() {
  if [[ -z ${no_colour-} ]]; then
    # Text attributes
    readonly ta_bold="$(tput bold 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_uscore="$(tput smul 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_blink="$(tput blink 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_reverse="$(tput rev 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_conceal="$(tput invis 2> /dev/null || true)"
    printf '%b' "$ta_none"

    # Foreground codes
    readonly fg_black="$(tput setaf 0 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_blue="$(tput setaf 4 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_cyan="$(tput setaf 6 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_green="$(tput setaf 2 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_magenta="$(tput setaf 5 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_red="$(tput setaf 1 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_white="$(tput setaf 7 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_yellow="$(tput setaf 3 2> /dev/null || true)"
    printf '%b' "$ta_none"

    # Background codes
    readonly bg_black="$(tput setab 0 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_blue="$(tput setab 4 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_cyan="$(tput setab 6 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_green="$(tput setab 2 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_magenta="$(tput setab 5 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_red="$(tput setab 1 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_white="$(tput setab 7 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_yellow="$(tput setab 3 2> /dev/null || true)"
    printf '%b' "$ta_none"
  else
    # Text attributes
    readonly ta_bold=''
    readonly ta_uscore=''
    readonly ta_blink=''
    readonly ta_reverse=''
    readonly ta_conceal=''

    # Foreground codes
    readonly fg_black=''
    readonly fg_blue=''
    readonly fg_cyan=''
    readonly fg_green=''
    readonly fg_magenta=''
    readonly fg_red=''
    readonly fg_white=''
    readonly fg_yellow=''

    # Background codes
    readonly bg_black=''
    readonly bg_blue=''
    readonly bg_cyan=''
    readonly bg_green=''
    readonly bg_magenta=''
    readonly bg_red=''
    readonly bg_white=''
    readonly bg_yellow=''
  fi
}


# DESC: Initialise Cron mode
# ARGS: None
# OUTS: $script_output: Path to the file stdout & stderr was redirected to
function cron_init() {
  if [[ -n ${cron-} ]]; then
    # Redirect all output to a temporary file
    readonly script_output="$(mktemp --tmpdir "$script_name".XXXXX)"
    exec 3>&1 4>&2 1>"$script_output" 2>&1
  fi
}


# DESC: Pretty print the provided string
# ARGS: $1 (required): Message to print (defaults to a green foreground)
#       $2 (optional): Colour to print the message with. This can be an ANSI
#                      escape code or one of the prepopulated colour variables.
#       $3 (optional): Set to any value to not append a new line to the message
# OUTS: None
function pretty_print() {
  if [[ $# -lt 1 ]]; then
    script_exit 'Missing required argument to pretty_print()!' 2
  fi

  if [[ -z ${no_colour-} ]]; then
    if [[ -n ${2-} ]]; then
      printf '%b' "$2"
    else
      printf '%b' "$fg_green"
    fi
  fi

  # Print message & reset text attributes
  if [[ -n ${3-} ]]; then
    printf '%s%b' "$1" "$ta_none"
  else
    printf '%s%b\n' "$1" "$ta_none"
  fi
}


# DESC: Only pretty_print() the provided string if verbose mode is enabled
# ARGS: $@ (required): Passed through to pretty_pretty() function
# OUTS: None
function verbose_print() {
  if [[ -n ${verbose-} ]]; then
    pretty_print "$@"
  fi
}


# DESC: Check a binary exists in the search path
# ARGS: $1 (required): Name of the binary to test for existence
#       $2 (optional): Set to any value to treat failure as a fatal error
# OUTS: None
function check_binary() {
  # Number of positional parameters set is less than 1
  if [[ $# -lt 1 ]]; then
    script_exit 'Missing required argument to check_binary()!' 2
  fi

  if ! command -v "$1" > /dev/null 2>&1; then
    if [[ -n ${2-} ]]; then
      script_exit "Missing dependency: Couldn't locate $1." 1
    else
      verbose_print "Missing dependency: $1" "${fg_red-}"
      return 1
    fi
  fi

  verbose_print "Found dependency: $1"
  return 0
}


# DESC: Validate we have superuser access as root (via sudo if requested)
# ARGS: $1 (optional): Set to any value to not attempt root access via sudo
# OUTS: None
function check_superuser() {
  local superuser test_euid
  if [[ $EUID -eq 0 ]]; then  # <EUID> equal 0
    superuser=true
  elif [[ -z ${1-} ]]; then
    if check_binary sudo; then
      pretty_print 'Sudo: Updating cached credentials ...'
      if ! sudo -v; then
        verbose_print "Sudo: Couldn't acquire credentials ..." \
          "${fg_red-}"
      else
        test_euid="$(sudo -H -- "$BASH" -c 'printf "%s" "$EUID"')"
        if [[ $test_euid -eq 0 ]]; then
          superuser=true
        fi
      fi
    fi
  fi

  if [[ -z ${superuser-} ]]; then
    verbose_print 'Unable to acquire superuser credentials.' "${fg_red-}"
    return 1
  fi

  verbose_print 'Successfully acquired superuser credentials.'
  return 0
}


# DESC: Run the requested command as root (via sudo if requested)
# ARGS: $1 (optional): Set to zero to not attempt execution via sudo
#       $@ (required): Passed through for execution as root user
# OUTS: None
function run_as_root() {
  if [[ $# -eq 0 ]]; then
    script_exit 'Missing required argument to run_as_root()!' 2
  fi

  local try_sudo
  if [[ ${1-} =~ ^0$ ]]; then
    try_sudo=true
    shift
  fi

  if [[ $EUID -eq 0 ]]; then
    "$@"
  elif [[ -z ${try_sudo-} ]]; then
    sudo -H -- "$@"
  else
    script_exit "Unable to run requested command as root: $*" 1
  fi
}


###  Scripts functions

# DESC: Setting AWS CLI region default to ~/.aws/config file
# ARGS: $1 (required): New Region to Setting Up
# OUTS: None
function setRegion() {
  [[ -n "$1" ]] || {
    echo "usage: "$(containsArray <array> [Region|Array])""
    echo "Return 0 in case exit_code right"
    return 2
  }
  local regionPassed=$1
  verbose_print "Changing default aws profile region..." "${fg_white-}"
  # To modify a specific line, we can use the (c) flag like this:
  if [ -f ~/.aws/config ]; then
    verbose_print "$(sed "2c\region = $regionPassed" ~/.aws/config)" \
      "${fg_yellow-}"
    region_id=$regionPassed
    verbose_print "Changed default profile region to $regionPassed" \
      "${fg_green-}" | report_env
    return 0
  else
    verbose_print "You must install aws cli" "${fg_blue-}"
    script_exit "No Found Path ~/.aws/config file." 2
  fi
}


# DESC: Check if exists value in array passed
# ARGS: $1 (required) Array where looking for value
#       $2 (required) Value to search in Array
# OUTS: 'yes' If array contains value, 'no' otherwise
function containsArray() {
  [[ -n "$1" && -n "$2" ]] || {
    echo "usage: "$(containsArray <Array> <Value>)""
    echo "Returns 'yes' If array contains value, 'no' otherwise"
    return 2
  }
  local n=$#      # ($#) give number elements + 1
  # echo "$n"
  local value=${!n} # value take the param to search into array
  # echo "$value"
  for ((i=1;i < $#;i++)) {
    if [ "${!i}" == "${value}" ]; then
      echo "yes"
      return 0
    fi
  }
  echo "no"
  script_exit "Invalid parameter was provided: ${value}. Use --help" 1
}


# DESC: Check a Region exists in the validate Region array
# ARGS: $1 (required): Image_id to Check in validate array
# OUTS: None
function checkRegion() {
  [[ -n "$1" ]] || {
    echo "Usage: checkRegion \"regionToCheck\")"
    echo "Returns 0 right, 1 otherwise"
    return 2
  }
  local regionPassed=$1
  if [ "$(containsArray "${regionsArray[@]}" "$regionPassed")" = "yes" ]; then
    setRegion "$regionPassed"
    return 0
  else
    script_exit "Invalid REGION was provided: $regionPassed. Use bash ./create-aws-ami.sh --help" 1
  fi

}


# DESC: Check a Ami exists in the validate Ami array
# ARGS: $1 (required): Image_id to Check in validate array
# OUTS: None
function checkAmi() {
  [[ -n "$1" ]] || {
    echo "Usage: chekAmi \"amiToCheck\""
    echo "Returns 0 right, 1 otherwise"
    return 2
  }
  local amiPassed=$1
  if [ "$(containsArray "${amisArray[@]}" "$amiPassed")" = "yes" ]; then
    image_id=$amiPassed
    verbose_print "Selected image_id: $image_id"
    return 0
  else
    script_exit "Invalid AMI was provided: $amiPassed. Use bash ./create-aws-ami.sh --help" 1
  fi
}


# DESC: Menu to select Region or Ami from Array gived
# ARGS: $1 (required): Type menu to show
# OUTS: Display menu to Select Region or Ami
function selectMenu() {
  [[ -n "$1" ]] || {
    echo "Usage: selectMenu [\"Region\"|\"Ami\"]"
    echo "Show display Menu to select Region or Ami"
    return 2
  }
  # "${arr[-1]}"                                 # Take last element in arr
  # unset arr[-1]                                # Delete last element in arr
  typeMenu=$1
  if [ $typeMenu = "Region" ]; then
    arr=("${regionsArray[@]}")
  elif [ $typeMenu = "Ami" ]; then
    arr=("${amisArray[@]}")
  fi

  echo -e "$typeMenu Selection:"
  menu=0              # Heading for region
  PS3="Select: "                                 # Set prompt for select menu
  while [ "$menu" != 1 ]; do                     # Outer loop redraws each time
    select choice in ${arr[@]}; do
      if [ "$(containsArray "${arr[@]}" "$choice")" = "yes" ]; then
        if [ $typeMenu = "Region" ]; then
          setRegion "$choice"
          menu=1
          break;
        elif [ $typeMenu =  "Ami" ]; then
          image_id=$choice
          verbose_print "Selected image_id: $image_id" \
            "${fg_green-}" | report_env
          menu=1
          break;
        fi
      else
        verbose_print "      No es un parametro valido. Intentelo denuevo !!!" \
          "${fg_yellow-}"
      fi
    done
  done
}


# DESC: Report Environment created in file resourcescreateID_XXXXXXX
# ARGS: None
# OUTS: None
function report_env {
  tee -a resourcesCreateID_$randomNumber
}

# DESC: Usage help
# ARGS: None
# OUTS: None
function script_usage() {
  cat << EOF
  # ########################################################################## #
  # create-aws-ami.sh                                                          #
  # Automation tool to create enviroment aws ec2 cloud.                        #
  # Allowing to launch several instances ami Free tier eligible.               #
  # (Filter 4 lastest Ubuntu linux).                                           #
  # Creates:                                                                   #
  #    - VPC, SUBNET, IGWDEFAULT, SECURITY GROUP, RULE SSH_PORT (22)           #
  #    - DNS and DNS Hostname Support                                          #
  #    · In case create 1 instance:                                            #
  #      - start-instanche-<randomNumber>.sh    # start tenant tool            #
  #      - stop-instanche-<randomNumber>.sh     # stop tenant tool             #
  #      - terminate-instance-<randomNumber>.sh # terminate/delete tenant tool #
  # ########################################################################## #
  Usage: create-aws-ami.sh [options] Wizard show menu to Select Region && Ami
         create-aws-ami.sh --region <region_id> --ami <image_id> [options]

  Desc: Create enviroment aws ec2 cloud in determinate aws Region.
        Launching several instance Free tier eligible ami.

  Note: Filter to 4 lastest Ubuntu in Region Selected.
        To modify Change amisArray filters

  Options:
     -h|--help                  Displays this help
     -v|--verbose               Displays verbose output
    -nc|--no-colour             Disables colour output
    -cr|--cron                  Run silently unless we encounter an error
EOF
}


# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
#       $1 (optional): Set to zero to not attempt execution via sudo
#       $2 (optional): Set to zero to not attempt execution via sudo
# OUTS: Variables indicating command-line parameters and options
function parse_params() {
  local param
  while [[ $# -gt 0 ]]; do
    param="$1"
    shift
    case $param in
      --region)
        if [[ $# -eq 0 ]]; then
          script_usage
          echo "${fg_red-}" "Error <region_id> has not value"
          exit 0
        else
          region_id="$1"
          shift
        fi
        ;;

      --ami)
        if [[ $# -eq 0 ]]; then
          echo "${fg_red-}" "Error <image_id> has not value"
          script_usage
          exit 0
        else
          image_id="$1"
          shift
        fi
        ;;
      -h|--help)
        script_usage
        exit 0
        ;;
      -v|--verbose)
        verbose=true
        ;;
      -nc|--no-colour)
        no_colour=true
        ;;
      -cr|--cron)
        cron=true
        ;;
      *)
        script_exit "Invalid parameter was provided: $param" 2
        ;;
    esac
  done
}

### Variables declarations
# Network Settings
vpc_cidr="10.0.0.0/24"
subnet_cidr="10.0.0.0/25"
igwdefault_cidr="0.0.0.0/0"
ssh_port="22"

#  Instance settings
region_id=""                                               # blank default zone
image_id=""                                                # ubuntu 14.04
# ssh_user_name="myUser" + "shuf -i 0-1000 -n 1"           # Not used yet
randomNumber=$(shuf -i 0-10000 -n 1)
ssh_key_name="myKey-$randomNumber"
instance_type="t2.micro"
subnet_id="subnet-xXxXxXX"
root_vol_size=10
count=1           # Now fixed count 1 (future param to create cluster instance)

#  Assign Tags
tag_Name="myAmi-$randomNumber"
tag_Owner="SilvaGlez"
tag_ApplicationRole="Lab"
tag_Environment="Alien-Lab-Dev"
tag_OwnerEmail="jaime.silva.glez@gmail.com"
tag_Project="AlienLab"
tag_SupportEmail="jaime.silva.glez@gmail.com"
# tag_BusinessUnit="Cloud AWS Engineering Lab"             # Not used yet
# tag_Cluster="Test Lab Cluster"                           # Not used yet



# DESC: Main Script control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {
  # Initialise Scripts Control, Debug, Verbose. Try using bests practices
  trap script_trap_err ERR
  trap script_trap_exit EXIT


  # Generic script initialisation
  script_init "$@"

  # Initialise colour variables
  colour_init

  # Initialise Cron mode
  cron_init

  # Parameter parser
  parse_params "$@"

  # check aws cli & jq installed
  check_binary aws
  check_binary jq


  ############     Script Code     ############

  # Array of validates regions to region_id var
  regionsArray=($(echo $(aws ec2 describe-regions --output table | head -n -1 | tail -n 15 | awk '{print $4}') | tr " " "\n"))
  if [[ $region_id = "" ]]; then
    selectMenu "Region"
  else
    checkRegion "$region_id"
  fi


  # Array of validates AMIS for selection to 'image_id' var
  # Looking for the 5 Latest Ubuntu 16.04 Server HVM AMI. Using defafult region
  # Now we will launch an EC2 Instance into our VPC. When looking for the
  # Latest Ubuntu 16.04 Server Linux HVM AMI
  amisArray=($(echo $(aws ec2 describe-images --filters "Name=name,Values=*ubuntu*xenial*16.04*server*" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" "Name=architecture,Values=x86_64" "Name=block-device-mapping.volume-size,Values=1,2,3,4,5,6,7,8,9,10" --query 'Images[*].[ImageId]' --output text  | sort -k2 -r  | head -n4)))
  if [[ $image_id = "" ]]; then
    selectMenu "Ami"
  else
    checkAmi "$image_id"
  fi

  echo "${fg_white-}"
  echo "Automate tool creating AWS Environment launching Ami:" | report_env
  ## Create the VPC, you will be returned with the vpcid
  echo "Creating aws Virtual Private Network to allocate instance"
  vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --query 'Vpc.VpcId' --output text)
  verbose_print  "Created aws Virtual Private Network where allocate the instance: $vpc_id" \
    "${fg_green-}" | report_env


  ## Enable DNS and DNS Hostname Support
  echo "Enabling DNS and DNS Hostname Support to instance"
  aws ec2 modify-vpc-attribute --vpc-id $vpc_id \
    --enable-dns-support "{\"Value\":true}" | report_env
  aws ec2 modify-vpc-attribute --vpc-id $vpc_id \
    --enable-dns-hostnames "{\"Value\":true}" | report_env
  verbose_print  "Enabled DNS and DNS Hostname Support to instance" \
    "${fg_green-}" | report_env


  ## Create an Internet Gateway
  echo "Creating an Internet Gateway" "${fg_white-}"
  igw_id=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
  verbose_print  "Created an Internet Gateway: $igw_id" \
    "${fg_green-}" | report_env


  ## Associate the Internet Gateway created to our VPC
  echo "Associating the Internet Gateway created to our VPC"
  aws ec2 attach-internet-gateway --internet-gateway-id $igw_id \
    --vpc-id $vpc_id | report_env
  verbose_print  "Attached the Internet Gateway created to VPC" \
    "${fg_green-}"| report_env


  ## Create a Subnet, Specify your CIDR, and associate it to your VPC.
  # Then create a Routing Table by specifying the VPC you would like to associate
  # the Routing Table to and then associate the returned routing table id with
  # your returned subnet id. Then create a routing entry to the default gateway
  # which will be the Internet Gateway (IGW)
  echo "Creating Subnet" "${fg_white-}"
  subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet_cidr --query 'Subnet.SubnetId' --output text)
  verbose_print  "Created Subnet: $subnet_id" "${fg_green-}" | report_env


  # Create Routing Table
  echo "Creating Routing Table" "${fg_white-}"
  routetbl_id=$(aws ec2 create-route-table --vpc-id $vpc_id --query 'RouteTable.RouteTableId' --output text)
  verbose_print  "Created Routing Table: $routetbl_id"  \
    "${fg_green-}" | report_env

  # Associate Routing Table with Subnet
  echo "Associating Routing Table with Subnet"
  aws ec2 associate-route-table --route-table-id $routetbl_id \
    --subnet-id $subnet_id | report_env
  verbose_print  "Associating Routing Table:  $routetbl_id, with Subnet: $subnet_id"\
    "${fg_green-}" | report_env


  # Create a Routing entry to the default Gateway
  echo "Creating a Routing entry to the default Gateway"
  aws ec2 create-route --route-table-id $routetbl_id \
    --destination-cidr-block $igwdefault_cidr --gateway-id $igw_id | report_env
  verbose_print  "Created a Routing entry to the default Gateway: $igwdefault_cidr" \
    "${fg_green-}" | report_env


  ## Create a Security Group
  echo "Creating a Security Group" "${fg_white-}"
  sg_id=$(aws ec2 create-security-group --group-name my-security-group --description "my-security-group" --vpc-id $vpc_id --query 'GroupId' --output text)
  verbose_print  "Created a Security Group: $sg_id" | report_env


  ## Add an inbound rule to allow SSH traffic from everywhere
  echo "Adding an inbound rule to allow SSH traffic from everywhere"
  aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp \
    --port $ssh_port --cidr $igwdefault_cidr
  verbose_print  "Added an inbound rule to allow SSH traffic from everywhere in port: $ssh_port" \
    "${fg_green-}" | report_env


  ## Create a KeyPair by connect to instance, output it save to disk:
  echo "Creating a KeyPair by connect to instance, output it save to disk"
  aws ec2 create-key-pair --key-name $ssh_key_name --query 'KeyMaterial' \
    --output text > ./$ssh_key_name.pem
  verbose_print  "Created a KeyPair by connect to instance, output it save to disk in ./$ssh_key_name.pem" \
    "${fg_green-}"| report_env


  ## Apply needed permissions to KeyPair file
  chmod 400 ./$ssh_key_name.pem
  verbose_print  "Applied needed permissions (mode 400) to KeyPair file" \
    "${fg_green-}" | report_env


  ## Launch EC2 Instance:
  echo "Creating instance..." "${fg_white-}"
  instance_id=$(aws ec2 run-instances --image-id $image_id --count $count --instance-type $instance_type --key-name $ssh_key_name --security-group-ids $sg_id --subnet-id $subnet_id --associate-public-ip-address --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": $root_vol_size } } ]" --query 'Instances[*].InstanceId' --output text)
  # --region $region
  verbose_print  "Ceated instance: $instance_id" "${fg_green-}" | report_env


  # tag it
  echo "Tagging $instance_id..." "${fg_white-}"
  aws ec2 create-tags --resources $instance_id --tags Key=Name,Value="$tag_Name" \
    Key=Owner,Value="$tag_Owner"  Key=ApplicationRole,Value="$tag_ApplicationRole" \
    Key=Environment,Value="$tag_Environment" Key=OwnerEmail,Value="$tag_OwnerEmail" \
    Key=Project,Value="$tag_Project" Key=SupportEmail,Value="$tag_SupportEmail"

  # Show the instance data created
  verbose_print  "Showing instance details..." "${fg_white-}"
  aws ec2 describe-instances --instance-ids $instance_id | report_env


  #####  CREATE START INSTANCE SCRIPT #####
  verbose_print  "Creating stop instance script" "${fg_white-}"
  echo -e  "#!/bin/bash" > start-instance-$randomNumber.sh
  echo -e  "aws ec2 start-instances --instance-ids $instance_id --output text | grep -w CURRENTSTATE | awk '{print \$3}'" \
    >> start-instance-$randomNumber.sh
  verbose_print "Created Start script ./start-instance-$randomNumber.sh" \
    "${fg_green-}" | report_env
  echo "To Start to Instance created use:" | report_env
  echo ./start-instance-$randomNumber.sh | report_env


  #####  CREATE STOP INSTANCE SCRIPT #####
  verbose_print  "Creating stop instance script" "${fg_white-}"
  echo -e  "#!/bin/bash" > stop-instance-$randomNumber.sh
  echo -e  "aws ec2 stop-instances --instance-ids $instance_id --output text | grep -w CURRENTSTATE | awk '{print \$3}'" \
    >> stop-instance-$randomNumber.sh
  verbose_print "Created Stop script ./stop-instance-$randomNumber.sh" \
    "${fg_green-}" | report_env
  echo "To Stop to Instance created use:" | report_env
  echo ./stop-instance-$randomNumber.sh | report_env


  #####  CREATE TERMINATE INSTANCE SCRIPT #####
  verbose_print  "Creating termination script" "${fg_white-}"
  echo -e  "#!/bin/bash" > terminate-instance-$randomNumber.sh
  echo -e  "aws ec2 terminate-instances --instance-ids $instance_id" \
    >> terminate-instance-$randomNumber.sh
  chmod +x terminate-instance-$randomNumber.sh
  verbose_print "Created Termination script ./terminate-instance-$randomNumber.sh" \
    "${fg_green-}" | report_env
  echo "To Terminate to Instance created use:" | report_env
  echo ./terminate-instance-$randomNumber.sh | report_env

  ## Get the Public IP by calling the Describe-Instances API call
  verbose_print  "Describe Instance Created:" "${fg_white-}"
  publicDnsName=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicDnsName')


  ## SSH into your EC2 Instance with your KeyPair and Public IP:
  echo "To Connect to Virtual Machine use:" | report_env
  echo ssh -i ./$ssh_key_name.pem ubuntu@${publicDnsName:1:-1} | report_env

  ## Aditionally, you can also tag your resource, by doing the following:
  #aws ec2 create-tag --resources "i-1234528abce88b44" --tag 'Key="ENV",Value=DEV'


  # To Finish this lab example will stop instance and terminate.
  # calling to script creates.
  echo "Waiting to finsh starting current instance created."
  echo "Next steps: Stop and Terminate Instance"
  sleep 30
  bash ./stop-instance-$randomNumber.sh
  bash ./terminate-instance-$randomNumber.sh


}  # End main function

# Make it rain
main "$@"
