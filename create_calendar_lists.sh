#!/bin/bash

# .envファイルから環境変数を読み込む
source .env

# 日付の範囲を入力（YYYY/MM/DD）
read -p "開始日を入力してください (形式: YYYY/MM/DD): " START_DATE
read -p "終了日を入力してください (形式: YYYY/MM/DD): " END_DATE

# TrelloのAPI URL
API_URL="https://api.trello.com/1/lists"

# 開始日と終了日をタイムスタンプに変換
START_TIMESTAMP=$(date -jf "%Y/%m/%d" "$START_DATE" +%s)
END_TIMESTAMP=$(date -jf "%Y/%m/%d" "$END_DATE" +%s)

# 曜日を日本語に変換する関数
get_weekday_jp() {
    local weekday=$1
    echo "[DEBUG] Input weekday: $weekday" >&2
    case $weekday in
        "Sun"|"日") echo "日" ;;
        "Mon"|"月") echo "月" ;;
        "Tue"|"火") echo "火" ;;
        "Wed"|"水") echo "水" ;;
        "Thu"|"木") echo "木" ;;
        "Fri"|"金") echo "金" ;;
        "Sat"|"土") echo "土" ;;
        *) echo "?" ;;
    esac
}

# 日付範囲内でループ
current_timestamp=$START_TIMESTAMP
while [ $current_timestamp -le $END_TIMESTAMP ]; do
    month=$(date -r $current_timestamp +"%-m")
    day=$(date -r $current_timestamp +"%-d")
    date_str="${month}/${day}"
    weekday_en=$(date -r $current_timestamp +"%a")
    weekday_jp=$(get_weekday_jp "$weekday_en")

    list_name="${date_str}(${weekday_jp})"

    echo "Creating list: $list_name"

    curl -X POST "$API_URL" \
      -d "name=$list_name" \
      -d "idBoard=$BOARD_ID" \
      -d "key=$API_KEY" \
      -d "token=$API_TOKEN" \
      -d "pos=bottom"
    current_timestamp=$((current_timestamp + 86400))
done

echo "すべてのリストを作成しました。"