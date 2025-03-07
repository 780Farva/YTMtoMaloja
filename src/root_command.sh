log info "~*~*~*~ LastTakeoutScraper ~*~*~*~"
# Give ourselves a temporary file to work with
# tmp_folder=/tmp/lts/$(uuidgen)
# tmp_folder=/tmp/lts/
tmp_folder=./tmp/lts
music_entries_only_file=${tmp_folder}/music_only.json
artist_names_file=${tmp_folder}/artists.txt

log info "I'll read from ${args[source]}, make some temporary files in ${tmp_folder} and write my results to ${args[out]}."

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

log info "Extracting artist names"
# write just the artists to a file
jq -r 'group_by(.artist) | map({artist: .[0].artist}) | .[].artist' ${music_entries_only_file} > ${artist_names_file}

echo "uts,utc_time,artist,track" > ${args[out]}
jq -r '.[] | [.uts, .utc_time, .artist, .track] | @csv' \
	${music_entries_only_file} >> ${args[out]}

log info "~*~*~*~ fin ~*~*~*~"