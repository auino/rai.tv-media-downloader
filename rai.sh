#!/bin/bash

BEFORECHECK=5
AFTERCHECK=10

FILESIZELIMIT=100000
RETRYNUM=100

PAR_OK=1
if [ $# -eq 0 ]; then PAR_OK=0; fi
if [[ "$1" -eq "-s" ]] && [[ $# -le 1 ]]; then PAR_OK=0; fi

if [ $PAR_OK -eq 0 ]; then
	echo "Usage: bash $0 [-s] <full_name>"
	echo " where -s identifies an episode search"
	echo " and <full_name> identifies the full search string (with spaces, if needed)"
	exit 0
fi

DIRNAME=`dirname $0`

FILTER=""
if [ "$1" = "-s" ]; then
	shift
	FILTER="%20st"
fi

ORIG_SEARCH="$@"

SEARCH=`echo $ORIG_SEARCH|sed -e 's/ /%20/g'`
cd $DIRNAME 2> /dev/null

URL="http://www.rai.tv/ricerca/search?q=$SEARCH$FILTER&sort=date:D:L:d1&filter=0&getfields=*&site=raitv&client=rai_tv2&start=0"

curl -s "$URL"|tr '>' '\n'|grep -v "_raw_content_"|grep "og_title" -A $AFTERCHECK -B $BEFORECHECK|grep -i "$ORIG_SEARCH" -A $AFTERCHECK -B $BEFORECHECK|grep -i -E "st.* ep" -A 10|grep "og_title\|videourl"|sed -e 's/&#8211;/-/g'|awk -F'"' '{print $4}'|sed -e 's/^\/\//http:\/\//g' > /tmp/data.txt

NAME=""
while read l; do
	if [ "$NAME" = "" ]; then
		NAME="$l"
	else
		URL="$l"
		if [ ${NAME::4} == "http" ]; then
			if [ ${URL::4} == "http" ]; then continue; fi
			TMP=$URL
			URL=$NAME
			NAME=$TMP
		fi
		echo "------------"
		echo "Found: \"$NAME\"."
		echo "URL: $URL"
		echo "Do you want to download it? [y/n]"
		read x < /dev/tty
		if [[ "$x" = "y" ]] || [[ "$x" = "Y" ]]; then
			echo "Downloading: \"$NAME\""
			echo "URL: $URL"
			rm "$NAME.mp4" 2> /dev/null
			DOWNLOADED=0
			while [ $DOWNLOADED -le 0 ]; do
				FILESIZE=`ls -l "$NAME.mp4"|awk '{print $5}' 2> /dev/null`
				if [[ "$FILESIZE" != "" ]] && [[ $FILESIZE -gt 0 ]]; then
					echo "Downloading from $FILESIZE"
					curl -L --retry $RETRYNUM --range ${FILESIZE}- "$URL" >> "./$NAME.mp4"
				else
					echo "Downloading entire file"
					curl -L --retry $RETRYNUM "$URL" >> "./$NAME.mp4"
				fi
				#echo "Result of curl: $?"
				if [ "$?" = "0" ]; then
					DOWNLOADED=1
				fi
			done
			FILESIZE=`ls -l "$NAME.mp4"|awk '{print $5}'`
			if [ $FILESIZE -le $FILESIZELIMIT ]; then
				URL=`cat "$NAME.mp4"|grep -e '^http'|tail -n 1`
				rm "$NAME.mp4"
				echo "Downloading final file from $URL"
				curl -s -L "$URL" > /tmp/data_list.txt
				while read l; do
					curl -s -L "$URL" >> "$NAME.mp4"
				done < /tmp/data_list.txt
			fi
		fi
		NAME=""
		echo "------------"
		echo ""
	fi
done < /tmp/data.txt

rm /tmp/data.txt 2> /dev/null

echo "Finished!"

exit 1
