#!/usr/bin/env bash

A1="ミラクルミュージカル"
T1="Dream Sweet in Sea Major"
A2="bbno$"
T2="sophisticated"


query_api() {
echo $(curl -s --get \
--data-urlencode 'fmt=json' \
--data-urlencode 'limit=100' \
--data-urlencode "$@" \
'https://musicbrainz.org/ws/2/recording/')
}



artist_track_pairs= ("ミラクルミュージカル" "Dream Sweet in Sea Major" "bbno$" "sophisticated")

query="query=status:(official OR promotion) AND ((title:\"${T1}\" AND artist:\"${A1}\") OR (title:\"${T2}\" AND artist:\"${A2}\"))" 

batch_size=2

for ((i = 0; i < ${#artist_track_pairs[@]}; i += batch_size)); do
		params="query=status:(official OR promotion) AND ("

    # Construct the query string for this batch
    for ((j = i; j < i + batch_size && j < ${#artist_track_pairs[@]}; j++)); do
        if [[ -z "$params" ]]; then
            params="(artist:\"${artist_track_pairs[$j]}\" AND title:\"${artist_track_pairs[$j+1]}\")"
        else
            params+=" OR (artist:\"${artist_track_pairs[$j]}\" AND title:\"${artist_track_pairs[$j+1]}\")"
        fi
    done
        params+=")"
		query_api "$params" | jq -c '.recordings | unique_by(.title, ."artist-credit"[0].name) | .[] | { title: .title, artist: ."artist-credit"[0].name  } '

done

# query_api "${query}" | jq -c '.recordings | unique_by(.title, ."artist-credit"[0].name) | .[] | { title: .title, artist: ."artist-credit"[0].name  } '
