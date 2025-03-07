log info "~*~*~*~ LastTakeoutScraper ~*~*~*~"
# Give ourselves a temporary file to work with
# tmp_folder=/tmp/lts/$(uuidgen)
# tmp_folder=/tmp/lts/
tmp_folder=./tmp/lts
music_entries_only_file=${tmp_folder}/music_only.json
unique_artist_tracks=${tmp_folder}/artist_tracks.json
tagged_uniques=${tmp_folder}/tagged_artist_tracks.json

log info "I'll read from ${args[source]}, make some temporary files in ${tmp_folder} and write my results to ${args[out]}"

mkdir -p $tmp_folder

jq '[.[] | select(.header == "YouTube Music") |
	select(has("subtitles")) |
	.artist = (.subtitles[].name) |
	.artist |= (sub(" - Topic"; "") | gsub("^\\s+|\\s+$"; "") ) |
	. += { uts: (.time | sub("\\.[[:digit:]]+"; "") | fromdateiso8601 ) } |
	. += { utc_time: .time} |
	. += { track: (.title | sub("Watched "; ""))} |
	del(.header, .time, .title, .activityControls, .titleUrl, .products, .subtitles)]' \
	${args[source]} > ${music_entries_only_file}

log debug "A music-only version of the input file has been written to ${music_entries_only_file}"

log debug "Collecting unique artist-track pairs..."
jq '[unique_by([ .artist, .track ]) | .[] | del(.uts,.utc_time)]' ${music_entries_only_file} > ${unique_artist_tracks}



# a function that gets additional track information from musicbrainz
# usage get-mb-data <track_name> <artist_name>
function get-mb-data () {
mb_result=$(curl -s --get \
--data-urlencode 'fmt=json' \
--data-urlencode 'limit=1' \
--data-urlencode "query=\"$1\" AND artist:\"$2\"" \
'https://musicbrainz.org/ws/2/recording/') 

echo $mb_result | jq -M 'select(.count != 0) |
. += {
		track: ( .recordings[0].title ),
	  track_mbid: ( .recordings[0].id ),
		artist: ( .recordings[0]."artist-credit"[0].name),
		artist_mbid: ( .recordings[0]."artist-credit"[0].artist.id),
		album: ( .recordings[0].releases[0].title ),
		album_mbid: ( .recordings[0].releases[0].id )} |
del(.created, .count, .offset, .recordings)'
}

# use those artist names to get info from musicbrainz
log info "Retrieving album data..."
echo "[" > $tagged_uniques
jq -c '.[]' < $unique_artist_tracks | while read -r line; do
  artist_name=$(echo "$line" | jq -r '.artist')
  track_name=$(echo "$line" | jq -r '.track')
		log debug  $artist_name $track_name
  recording=$(get-mb-data "$track_name" "$artist_name")
  if [[ -n $recording ]]; then
    # Capture the result into a new file
		log debug "."
    echo "${recording}," >> $tagged_uniques
  fi
done


# echo "uts,utc_time,artist,track" > ${args[out]}
# jq -r '.[] | [.uts, .utc_time, .artist, .track] | @csv' \
# 	${music_entries_only_file} >> ${args[out]}

log info "~*~*~*~ fin ~*~*~*~"