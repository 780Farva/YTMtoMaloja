log info "~*~*~*~ LastTakeoutScraper ~*~*~*~"
# Give ourselves a temporary file to work with
# tmp_folder=/tmp/lts/$(uuidgen)
# tmp_folder=/tmp/lts/
tmp_folder=./tmp/lts/
music_entries_only_file=${tmp_folder}/music_only.json

log info "I'll read from ${args[source]}, make some temporary files in ${tmp_folder} and write my results to ${args[out]}."

mkdir -p $tmp_folder

jq -r '.[] | select(.header == "YouTube Music") |
	select(has("subtitles")) |
	.artist = (.subtitles[].name) |
	.artist |= sub(" - Topic"; "") |
	. += { uts: (.time | sub("\\.[[:digit:]]+"; "") | fromdateiso8601 ) } |
	. += { utc_time: .time} |
	. += { track: (.title | sub("Watched "; ""))} |
	del(.header, .time, .title, .activityControls, .titleUrl, .products, .subtitles) |
	[.uts, .utc_time, .artist, .track] | @csv' \
	${args[source]} > ${music_entries_only_file}


log debug "A music-only version of the input file has been written to ${music_entries_only_file}"


log info "~*~*~*~ fin ~*~*~*~"