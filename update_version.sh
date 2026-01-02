
PREV=1.0.0
CURR=1.0.1
echo "updating APP_VERSION: ${PREV} -> ${CURR}"
sed -i '' "s/APP_VERSION=${PREV}/APP_VERSION=${CURR}/" .env