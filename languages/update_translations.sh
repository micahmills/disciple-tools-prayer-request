# This script generates the .pot file, uploads it to poeditor and downloads the .po and .mo files for each language
# Pass in script: ./update_translations.sh -t 'token'

APP_ID='539529';
POT_FILE_NAME="languages/default.pot"
DOMAIN="disciple-tools-prayer-requests"

while getopts t: option
do
case "${option}"
in
t) TOKEN=${OPTARG};;
esac
done

if [ ! $TOKEN ]
 then echo "please enter poeditor token";
 exit 1
fi

# create new .pot file
wp i18n make-pot . $POT_FILE_NAME


#upload the .pot file to poeditor if there are any new translation strings
NUMBER_POT_LINE_CHANGES=$(git diff --shortstat "$POT_FILE_NAME" |  sed -E 's/.* ([0-9]+) insertion.* ([0-9]+) deletion.*/\1'/)
if [[ NUMBER_POT_LINE_CHANGES > "1" ]]
  then
    echo "uploading new .pot file"

    #upload file to poeditor
    curl -X POST https://api.poeditor.com/v2/projects/upload \
         -F api_token=$TOKEN \
         -F id=$APP_ID \
         -F updating="terms" \
         -F file=@"$POT_FILE_NAME" \
         -F tags="{\"obsolete\":\"removed-strings\"}"
  else
    echo "no new translation strings"
    git checkout $POT_FILE_NAME #undo file update date change
fi


#Download .po and .mo files
php ./languages/download-poeditor-updates.php --token="$TOKEN" --app-id="$APP_ID" --domain="$DOMAIN"

#Commit changes
git add *.pot;
git add *.po;
git add *.mo;
#git commit -m "Update Translations";
# git push origin master?
