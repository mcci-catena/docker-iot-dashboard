#!/bin/bash
# This script will create htpasswd for each controlled services for migration Apache->Nginx
read -r -p "Please enter .env file location : " envi

if [[ ! -f $envi ]]
then
	echo "Please enter correct file location"
	exit
fi

# $1 is the file to read. Result is one setting per line, name followed by single space
# followed by value. We can't source the .env file because it's really a .ini file and
# doesn't follow shell syntax.
function _parseenv {
	sed -n -e 's/#.*$//g' -e 's/^[ \t]*//' -e 's/[ \t]*=[ \t]*/=/' -e 's/^\([A-Za-z0-9_][A-Za-z0-9_]*\)=\(.*\)$/\1 \2/p' "$1"
}

TTN_DASHBOARD_DATA="$(_parseenv "$envi" | sed -ne 's/^TTN_DASHBOARD_DATA //p')"

htgroup="${TTN_DASHBOARD_DATA}docker-apache2/authdata/.htgroup"
htpasswd="${TTN_DASHBOARD_DATA}docker-apache2/authdata/.htpasswd"

PS3="Please enter your choice on the number listed above, To exit press 'ctrl+d '  :  "
select var in "creating htpasswd for each controlled service manually" "creating htpasswd for each controlled service automatically"
do
case $var in

	"creating htpasswd for each controlled service manually")
		PS3="Please select service: "
		select output in $(sed 's/:.*$//' "$htgroup")
		do
			true > "${output}_htpasswd"


			for i in $(tr < "$htgroup" ' |,' '\n' | sed 's/.*:$//' | sort -u)
			do
				read -r -p "Do you want the User: $i to be added in .htpasswd (y/n) : " j
				case $j in

				[yY][eE][sS]|[yY])

						sed -n "/$i/p" "$htpasswd" >> "${output}_htpasswd"
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
		done
		echo " "
		echo " "
		echo " "
		echo "It is done. Thanks!"
		echo " "
		echo " "
                exit
    	;;

	"creating htpasswd for each controlled service automatically")
		while read -r line
		do
			file=$(echo "$line" | awk '{print $1}' | sed 's/://')
			echo "create:" "${file}_htpasswd"
			true > "${file}_htpasswd"
			for k in $(echo "$line" | tr ' |,' '\n')
        		do
				sed -n "/$k/p" "$htpasswd" >> "${file}_htpasswd"
	        	done
		done < "$htgroup"
		echo " "
		echo " "
		echo " "
		echo "It is done. Thanks!"
		echo " "
		echo " "
		exit
		;;

    *)
		echo "Please enter correct number"
		;;
esac
done