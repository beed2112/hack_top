alias myperms='sudo chown -R eric .; sudo chgrp -R eric .'

alias myniktoit='nikto -host http://$targetHTTP | tee $targetHTTP.NIKTO.txt'

alias myhttpdpy='python3 -m http.server'
alias mywpscan='wpscan --enumerate ap --plugins-detection aggressive  --url '

alias mywebserver='docker run -it --rm -p 8090:8000 -v $PWD:/app/public --name gohttpserver docker.io/codeskyblue/gohttpserver:latest --upload --auth-type http --auth-http smokingjoe:smokingjoe'



#alias htbacademy='sudo openvpn /home/$USER/Downloads/Academy_Lab_${USER}.ovpn'


alias myffuf='ffuf -recursion -recursion-depth 1 -t 50 -fc 403 -e .php,.ini,.txt -w /usr/share/wordlists/dirb/big.txt -o $targetHTTP-$targetPortHTTP-fuff.json -u http://$targetHTTP:$targetPortHTTP/FUZZ '




alias ll='ls -lahF'
alias targetIP='export targetIP=`cat box`;echo $targetIP'
alias mydecode='base64 -d -i  <<< '
alias myencode='base64  -i  <<< '
alias c='clear'
alias ..='cd ..'
alias aliases='alias | grep '
alias gh='history | grep '
alias now='date +%Y-%m-%d'


alias myexternalip="echo `curl -s  http://ifconfig.io/ `"

alias reloadalias='. ~/.bash_aliases; . ~/.bash_functions ; . ~/.bash_aliases_docker'
#
alias myweather="curl wttr.in"
alias myupdate="sudo apt update;sudo apt full-upgrade -y"
