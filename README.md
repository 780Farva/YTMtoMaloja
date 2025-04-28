# YTMtoMaloja

A little project to convert Google Takeout dumps of YouTube Music listening history to a JSON format compatible with Maloja data exports.


# Installation
This is a bash project so just clone the repo, or download just the ytmaloja file and place it somewhere you can reach it from your terminal.

## Dependencies
- [jq](https://github.com/bobbyiliev/introduction-to-bash-scripting/blob/main/ebook/en/content/018-working-with-json-in-bash-using-jq.md)

# Usage

```bash
ytmaloja ./watch-history.json
```

## Getting Your watch-history.json from Google
1. Go to Google Takeout

    Open [Google Takeout](https://takeout.google.com/settings/takeout).


2. Deselect all services

    Deselect all the services that you don't want to download. You can leave only YouTube and YouTube Music selected.
    <p style="text-align: center;">
    <img src=./docs/step2.gif>
    </p>

3. Select YouTube content option

    Select "YouTube" as the content option.
    <p style="text-align: center;">
    <img src=./docs/step3.gif>
    </p>

4. Choose export format

    Click the button that says "Multiple Formats" to open up a dialog where you can select formats for different data. Scroll to find "history" and choose "JSON" as the export format (the default is HTML). This will ensure that your watch history is exported in JSON format, which is required by this program.

    >**Bonus:** If you want to minimize the time it takes to do all this, also click the button that says "All YouTube data included", click "Deselect all" in the dialog that pops up, and only select "history".

    <p style="text-align: center;">
    <img src=./docs/step4.gif>
    </p>

5. Create export

    Click on "Next step", review the options given to you and finally click the "Create export" button to start the process. You will be emailed a link with a zip file that contains your YouTube watch history if thats what you chose. Otherwise wait for your file to become available in whichever mode you selected.

    <p style="text-align: center;">
    <img src=./docs/step5.gif>
    </p>

6. Unzip the file

    Unzip the zip file and find the watch-history.json file inside. This file contains your YouTube watch history in JSON format! Make note of where you've saved it to.

### Input Example

```json
[{
  "header": "YouTube Music",
  "title": "Watched You Got One Too",
  "titleUrl": "https://music.youtube.com/watch?v\u003d4hvGypikiXo",
  "subtitles": [{
    "name": "Idle Garden - Topic",
    "url": "https://www.youtube.com/channel/UCuwGBVfSeLIwtAdCqUPKDjw"
  }],
  "time": "2025-04-28T12:23:47.000Z",
  "products": ["YouTube"],
  "activityControls": ["YouTube watch history"]
},

... more entres ...
some might look like this, and we want to filter them out since theyre not YouTube Music
{
  "header": "YouTube",
  "title": "Watched Old School Tech is better than LCD?! #gadgets #review #aliexpress #lcd #display",
  "titleUrl": "https://www.youtube.com/watch?v\u003dJ0md-P3Zq7g",
  "subtitles": [{
    "name": "GreatScott!",
    "url": "https://www.youtube.com/channel/UC6mIxFTvXkWQVEHPsEdflzQ"
  }],
  "time": "2025-03-04T16:15:58.427Z",
  "products": ["YouTube"],
  "activityControls": ["YouTube watch history"]
}.

... followed by about a bajillion more entries
]
```


### Output Example

```json
{
   "maloja": {
      "export_time": 1745800818
   },
   "scrobbles": [
      {
         "time": 1745799827,
         "track": {
            "artists": [
               "Idle Garden"
            ],
            "title": "You Got One Too",
            "album": null,
            "length": null
         },
         "duration": null,
         "origin": "client:YTMtoMaloja"
      },
      ... other entires ...
   ]
}
```


# Future Work

You may have noticed that at the moment this project leaves the album field empty.
Using an API like Musicbrainz or AudioDB is left as future work.

# Developing

This project uses [Bashly](https://github.com/DannyBen/bashly)!
If you'd like to pull it and modify it, understanding how to work within bashly projects is the place to start.