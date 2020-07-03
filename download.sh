#!/usr/bin/env bash


userAgent='Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0'

getEp(){

list=`echo ${1:-$(</dev/stdin)}`
read -r -a array <<< $list
order=1
for episode in ${array[@]}; 
do
	echo -e "\e[33m[*]Downloading episode $order\e[0m"
	if test -f $order.mp4;
	then
		echo -e "\e[32m[Episode $order.mp4 downloaded!\e[0m"
		order=$((order+1))
		continue
	fi
	
	curl -s -b "`cat ~/cookie`" \
	-A "$userAgent" \
	"$episode" | \
	grep '/e/' | \
	awk '{print $6}' | \
	sed -nr 's/.*"(.*)".*/\1/p' | \

	xargs -ISRC \
	curl -s -b "`cat ~/cookie`" \
	-A "$userAgent" \
	https://www1.animeultima.toSRC | \
	grep eval| \
	node 2>&1 | \
	grep fone  | \
	tr ';' '\n' | \
	grep fone -m1| \
	sed -nr 's/.*"(.*)".*/\1/p' | \

	xargs -I{} \
	curl -s -o $order.mp4 {}	
	order=$((order+1))
	if test -f "$((order-1)).mp4";
	then
		echo -e "\e[32m[+]Episode $((order-1)) downloaded!\e[0m"
	else 

		echo -e "\e[31m[-]Episode $((order-1)) failed to download\n[*]Forcing player to AUEngine...\e[0m"
		force=`curl -s -b "$(cat ~/cookie)" \
				-A "$userAgent" \
				"$episode" | \
				grep -i auengine | \
				sed -nr 's/.*"(.*)".*/\1/p' | \
				head -n1`
		#echo $force
		echo -e "\e[33m[*]Downloading episode $((order-1))\e[0m"
    	curl -s -b "`cat ~/cookie`" \
    	-A "$userAgent" \
		"$force" | \
	    grep '/e/' | \
	    awk '{print $6}' | \
	    sed -nr 's/.*"(.*)".*/\1/p' | \

    	xargs -ISRC \
	    curl -s \
	    -b "`cat ~/cookie`" \
	    -A "$userAgent" \
	    https://www1.animeultima.toSRC | \
	    grep eval| \
	    node 2>&1 | \
	    grep fone  | \
	    tr ';' '\n' | \
	    grep fone -m1| \
	    sed -nr 's/.*"(.*)".*/\1/p' | \

    	xargs -I{} \
	    curl -s -o $((order-1)).mp4 {}    
		if test -f "$((order-1)).mp4";
		then
			echo -e "\e[32m[+]Episode $((order-1)) downloaded!\e[0m"
		else
			
			echo -e "\e[31m[-]Failed to download episode $((order-1)) \e[0m"
		fi	
	fi
done

}

getList(){
id=`echo ${1:-$(</dev/stdin)}`
curl -s  \
-b "`cat ~/cookie`" \
"https://www1.animeultima.to/api/episodeList?animeId=$id" \
-A "$userAgent" | \
jq -r '.episodes[].urls.sub' | \
tac 
}

curl -s  \
 -b "`cat ~/cookie`" \
 "$1" \
-A "$userAgent" | \
 grep episode-list | \
 sed -nr 's/.*"(.*)".*/\1/p' | getList | getEp
