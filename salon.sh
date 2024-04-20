#!/bin/bash

# Function to display services
display_services() {
  SERVICES=$(psql -A -t --username=freecodecamp --dbname=salon -c "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "Services:"
  echo "$SERVICES" | while read -r line; do
    ID=$(echo $line | awk -F'|' '{print $1}')
    NAME=$(echo $line | awk -F'|' '{print $2}')
    echo "$ID) $NAME"
  done
}

# Function to get service name
get_service_name() {
  SERVICE_NAME=$(psql -A -t --username=freecodecamp --dbname=salon -c "SELECT name FROM services WHERE service_id = $1;")
  echo $SERVICE_NAME
}

# Function to check if service exists
service_exists() {
  if [[ $1 =~ ^[0-9]+$ ]]; then
    EXISTS=$(psql -A -t --username=freecodecamp --dbname=salon -c "SELECT COUNT(*) FROM WHERE service_id = $1;")
    if [ "$EXISTS" -eq "0" ]; then
      return 1
    else
      return 0
    fi
  else
    return 1
  fi
}

# Function to check if customer exists
customer_exists() {
  EXISTS=$(psql -A -t --username=freecodecamp --dbname=salon -c "SELECT COUNT(*) FROM customers WHERE phone = '$1';")
  if [ "$EXISTS" -eq "0" ]; then
    return 1
  else
    return 0
  fi
}

# Function to add customer
add_customer() {
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (phone, name) VALUES ('$1', '$2');"
}

# Function to add appointment
add_appointment() {
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) SELECT customer_id, $1, '$3' FROM customers WHERE phone = '$2';"
}

# Main script
while true; do
  display_services
  echo "Please enter service_id:"
  read SERVICE_ID_SELECTED
  if service_exists $SERVICE_ID_SELECTED; then
    break
  else
    echo "Invalid service_id. Please try again."
  fi
done

echo "Please enter phone number:"
read CUSTOMER_PHONE
if ! customer_exists $CUSTOMER_PHONE; then
  echo "Please enter your name:"
  read CUSTOMER_NAME
  add_customer $CUSTOMER_PHONE $CUSTOMER_NAME
else
  CUSTOMER_NAME=$(psql -A -t --username=freecodecamp --dbname=salon -c "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
fi

echo "Please enter service time:"
read SERVICE_TIME
add_appointment $SERVICE_ID_SELECTED $CUSTOMER_PHONE $SERVICE_TIME

SERVICE_NAME=$(get_service_name $SERVICE_ID_SELECTED)
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

exit 0