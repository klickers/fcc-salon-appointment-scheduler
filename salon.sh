#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

function MAIN_MENU {
  # show available services
  GET_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo -e "\nChoose an available service:"
  echo "$GET_SERVICES" | while read ID BAR NAME
  do
    echo "$ID) $NAME"
  done
  # get service number from user
  echo -e "\nWhich service would you like?"
  read SERVICE_ID_SELECTED
  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU
  else
    # if service doesn't exist
    GET_SERVICE_DESIRED=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $GET_SERVICE_DESIRED ]]
    then
      MAIN_MENU
    else
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      BOOK_SERVICE $SERVICE_ID_SELECTED $SERVICE_NAME
    fi
  fi
}

function BOOK_SERVICE {
  SERVICE_ID=$1
  SERVICE_NAME=$2

  # get customer details
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # if customer doesn't exist
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nWhat is your name?"
    read CUSTOMER_NAME
    CREATE_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  # get service time
  echo -e "\nWhen would you like to come in for an appointment?"
  read SERVICE_TIME
  # create appointment
  CREATE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
