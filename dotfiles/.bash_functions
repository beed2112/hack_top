smbservehere() {
    local sharename
    [[ -z $1 ]] && sharename="SHARE" || sharename=$1
    docker run --rm -it  --network host -p 445:445 -v "${PWD}:/tmp/serve" rflathers/impacket smbserver.py -smb2support $sharename /tmp/serve
}

# get a list of the docker aliases define
dockerstuff() {
  for line in `alias | grep docker | grep run | sed 's/=/ /' | awk '{print $2}'`;
    do 
      echo $line
   done
}


mkdircd() {
  mkdir $1 && cd $_
}

myfind() {
    sudo find / -name "$1" 2>/dev/null
}

save_env_script() {
    # Specify the variables you want to capture
    vars=("targetIP" "targetHTTP" "targetPortHTTP" "httpType" "myIP")
    
    # Define the output script name
    output_script="save_env.sh"

    # Create the script file and write a header
    echo "#!/bin/bash" > "$output_script"
    echo "# Script to set environment variables" >> "$output_script"

    # Loop through the specified variables
    for var in "${vars[@]}"; do
        if [[ -n ${!var} ]]; then
            echo "export $var='${!var}'" >> "$output_script"
        fi
    done

    # Make the script executable
    chmod +x "$output_script"

    echo "Environment variables saved to $output_script"
}
