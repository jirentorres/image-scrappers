#!/usr/bin/env bash

function version(){
	echo "ImageScrapper-Yandex 1.0"
	exit 0
}

if [[ "$1" == "" || "$1" == "-h" || "$1" == "--help" ]]; then
	echo "Usage: is-yandex.sh [QUERY] [FLAGS]"
	echo -e "\nOptions:"
	echo -e "  -i, --images\trequests images (default 30)"
	echo -e "  -o, --out-dir\t\toutput directory"
	echo -e "  -U, --user-agent\tUser-Agent (default Firefox/149.0)"
	echo -e "  -v, --version\t\tPrint version"
	echo -e "  -h, --help\t\tPrint help"
	exit 0
fi

cookie="spravka=dD0xNzg4NTQwNzI5O2k9MTQ5Ljg4LjEwNC4xMjtEPTBCNTlFRjdERDdGRDc0MDdDRjEwMEVEMjI0QUM2QzlBOTdGMERDMkU1NUE3QTg1QThCMkVDMjJFNTE3MjIyRDBDREZGMDI2MTEzNEY3QzY2MUE3MkM2M0M2MjU1MDY4RUMwMjBFODNBODhDOEUxQUQzMENGRDU4NjE5ODBEMTZGRDVDQTNCMjgxNEJCM0FDOTdEMjk5RDJDQUVDQkUxO3U9MTc4ODU0MDcyOTYxNTY1OTUxNjtoPWFmMjM3NmM0YTRiOTM2MTBmZTIzOWU0MWZkNmY1Zjgx"
query=""
images=30
outDir=""
userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:149.0) Gecko/20100101 Firefox/149.0"

#FLAGS
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--images)
            images="$2"
            shift 2
            ;;
        -o|--out-dir)
            outDir="$2"
            shift 2
            ;;
        -U|--user-agent)
            userAgent="$2"
            shift 2
            ;;
        -v|--version)
            version
            exit 0
            ;;
        -*)
            echo "Flag [$1] no existe!" >&2
            exit 1
            ;;
        *)
            if [[ -z "$query" ]]; then
                query="$1"
            fi
            shift
            ;;
    esac
done

function main(){
	if [[ -z "$outDir" ]]; then outDir="$query"; fi
	queryText=$(echo -n "${query}" | perl -pe 's/([^a-zA-Z0-9\Q.-_\E])/sprintf("%%%02X", ord($1))/ge')
	iterations=$(( (images + 30 - 1) / 30 ))
	for ((n=0;n<=$iterations;n++)); do
		curl_firefox147 -s -H "User-Agent: ${userAgent}" -H "Referer: https://yandex.com/images" -H "Cookie: $cookie" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-User: ?1" -H "Priority: u=0, i" "https://yandex.com/images/search?serpListType=horizontal&text=${queryText}&tmpl_version=releases-frontend-images-v1.1850.0__ea75361326b87045f4c1be447823d901a232c80b&uinfo=sw-2048-sh-1080-ww-1358-wh-619-pd-2-wp-16x9_2560x1440&p=${n}" | htmlq 'div.Root' | sed 's/img_url=/\n/g; s/%3Fnii%3D/\n/g; s/\&amp/\n/g' | grep ^https | perl -pe 's/\+/\ /g;' -e 's/%(..)/chr(hex($1))/eg;' >> scrapped_images
	done

	sort -u scrapped_images > scrapped_images_sort
	head -n $images scrapped_images_sort > scrapped_images

	aria2c -U "$userAgent" -j 10 -x 16 -s 16 -c --timeout=5 --max-tries=3 --disable-ipv6 -d "${outDir}" -i scrapped_images

	#bulk-rename
	#rename -n -e 'our $i; $i++; my ($ext) = /\.([^.]+)$/; $_ = sprintf("DIR_NAME%d.%s", $i, $ext)' DIR_NAME/*

	#clean links
	rm ./scrapped_images ./scrapped_images_sort
}

main
