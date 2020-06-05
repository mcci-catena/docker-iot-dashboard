#!/bin/bash
# This Script will create htpasswd for each controlled services for migration Apache->Nginx 
read -p "Please enter .env file location : " envi

	if [[ ! -f $envi ]]
	then
   		echo "Please enter correct file location"
   		exit
	fi
source $envi
htgroup=${IOT_DASHBOARD_DATA}docker-apache2/authdata/.htgroup
htpasswd=${IOT_DASHBOARD_DATA}docker-apache2/authdata/.htpasswd

PS3="Please enter your choice on the number listed above, To exit press 'ctrl+d '  :  "
select var in "creating htpasswd for each controlled service manually" "creating htpasswd for each controlled service automatically"
do
case $var in

	"creating htpasswd for each controlled service manually") 

		read -p "please let me know the output file name of .htpasswd for which controlled service : " output
		if [[ -z $output ]]
		then
   			echo "Please enter output file name"
   			exit
		fi
		> ${output}_htpasswd


		for i in $(cat $htgroup | xargs | tr ' |,' '\n' | sed 's/.*:$//' | sort -u)
		do
			read -p "Do you want the User: $i to be added in .htpasswd (y/n) : " j
			case $j in

	    		[yY][eE][sS]|[yY])
		 
					sed -n "/$i/p" $htpasswd >> ${output}_htpasswd
					;;
	        
	        	[nN][oO]|[nN])   
			
			        continue
					;;
		        *)
	                echo "Please Enter yes or no"
	                break
					;;
			esac
		done
    	;;

	"creating htpasswd for each controlled service automatically")
		while read -r line
		do
			file=$(echo "$line" | awk '{print $1}' | sed 's/://') 
			> ${file}_htpasswd
			for k in $(echo "$line" | xargs | tr ' |,' '\n')
        	do
				sed -n "/$k/p" $htpasswd >> ${file}_htpasswd
	        done
		done < "$htgroup"
		;;

    *)
		echo "Please enter correct number"
		;;
esac		
done
