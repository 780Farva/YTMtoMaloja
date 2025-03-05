log info "~*~*~*~ YTMtoMaloja ~*~*~*~"

if [[ -n "${args[--timestamp]}" ]]; then
    export_time="${args[--timestamp]}"
else
    export_time=$(date +%s)
fi

outfile="${args[out_dir]}/maloja_export${export_time}.json"

log debug ${args[out_dir]}

log info "I'll read from ${args[source]} and write my results to ${outfile}"

process_data() {
  jq '[.[] | select(.header == "YouTube Music") |
			select(has("subtitles")) |
			.time |= (sub("\\.[[:digit:]]+"; "") | fromdateiso8601 ) |
			. += { track: { "artists": [(.subtitles[].name | sub(" - Topic"; ""))]}} |
			.track.title = (.title | sub("Watched "; ""))|
			.track.album = null |
			.track.length = null |
			.duration = null |
      .origin = ("client:YTM") | 
      del(.header, .subtitles, .title,  .activityControls, .titleUrl, .products)]'
}

processed_data=$(process_data < "${args[source]}")

log debug "data preprocessing complete. ${processed_data}"

echo $processed_data | \
jq --arg export_time $export_time -aM \
'{ "maloja": {"export_time": $export_time}, 
"scrobbles": [.[]] }' > $outfile

log info "~*~*~*~ fin ~*~*~*~"