#!/bin/sh

# dock栏需要移除的应用
appsToRemoveIcons=(
    "Siri" 
    "Contacts" 
    "Notes" 
    "Reminders" 
    "Maps" 
    "Photos" 
    "Messages" 
    "FaceTime" 
    "Pages" 
    "Numbers" 
    "Keynote" 
    "iTunes" 
    "iBooks" 
    "App%20Store")

# Applications 是否安装此应用
# 1:应该移除；0:其他 
isShouldRemoveIcon=0
# 传入 appFile 
function shouldRemoveIconWithAppFile()
{
    appFile=$1
    for remIcon in $appsToRemoveIcons
    do
        remIconFile="file:///Applications/$remIcon.app/"
        echo ">> remIconFile - shouldRemoveIconWithAppFile: $remIconFile"
        echo ">> appFile - shouldRemoveIconWithAppFile: $appFile"
        if [[ $remIconFile == $appFile ]] 
        then
            isShouldRemoveIcon=1
            return
        fi
    done
}


dock_plist=/Library//Preferences/com.apple.dock.plist
# dock_plist=./com.apple.dock.plist
plistbuddy=/usr/libexec/PlistBuddy

# Move plist data to left.  key:"orientation"   value:"left"
$plistbuddy -c 'Add :orientation string left' $dock_plist


for((i=0;;i++));
do
    echo $i
    # 获取 key
    persistentApp=$($plistbuddy -c "Print :persistent-apps:$i" $dock_plist)

    echo "persistentApp: $persistentApp"
    if [ -z $persistentApp ]
    then
        echo "Print: Entry, ':persistent-apps', Does Not Exist"
        exit
    fi

    tile_data=$($plistbuddy -c 'Print :persistent-apps:0:tile-data' $dock_plist)
    if [ -z tile_data ]
    then
        echo "Print: Entry, ':tile_data', Does Not Exist"
        return
    fi

    CFURLString=$($plistbuddy -c 'Print :persistent-apps:0:tile-data:_CFURLString' $dock_plist)
    if [ -z $CFURLString ]
    then
        echo "Print: Entry, ':CFURLString', Does Not Exist"
        return
    fi
    echo ">> CFURLString: $CFURLString"

    shouldRemoveIconWithAppFile $CFURLString
    echo ">> isShouldRemoveIcon: $isShouldRemoveIcon"
    if [[ $isShouldRemoveIcon == 1 ]]
    then
        $plistbuddy -c "Delete :persistent-apps:$i" $dock_plist
    fi
done


