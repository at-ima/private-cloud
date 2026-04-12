#!/bin/sh
# MP4/動画プレビュー生成に必要な設定を occ で適用する
php /var/www/html/occ config:system:set enable_previews --value="true" --type=boolean
php /var/www/html/occ config:system:set enabledPreviewProviders 0 --value="OC\\Preview\\Image"
php /var/www/html/occ config:system:set enabledPreviewProviders 1 --value="OC\\Preview\\Movie"
php /var/www/html/occ config:system:set enabledPreviewProviders 2 --value="OC\\Preview\\TXT"
php /var/www/html/occ config:system:set enabledPreviewProviders 3 --value="OC\\Preview\\MP3"
php /var/www/html/occ config:system:set enabledPreviewProviders 4 --value="OC\\Preview\\MKV"
php /var/www/html/occ config:system:set enabledPreviewProviders 5 --value="OC\\Preview\\MP4"
php /var/www/html/occ config:system:set enabledPreviewProviders 6 --value="OC\\Preview\\AVI"
