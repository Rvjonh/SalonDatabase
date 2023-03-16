#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


MAIN_MENU(){
  
  #if a message is passed it will be printed
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #Show menu
  services=$($PSQL "SELECT * FROM services;")
  echo "$services" | while read SERVICE_ID BAR SERVICE
  do
    if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
    then
      echo "$SERVICE_ID) $SERVICE"
    fi
  done
  read SERVICE_ID_SELECTED

  #if the id is a number
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #check if it exists
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    if [[ -z $SERVICE_ID ]]
    then
      MAIN_MENU "Please enter a valid service."
    else
      #Get user information
      echo -e "\nEnter your phone number:"
      read CUSTOMER_PHONE

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

      #Create user in case user does not exist
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\nEnter your name:"
        read CUSTOMER_NAME
        q=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
      fi

      #take time the appointment will be
      echo -e "\nEnter your service time:"
      read SERVICE_TIME

      #set appointment
      q=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")

      #Get information of the appointment
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID;")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;")

      SERVICE_NAME=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
      CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  else
    #Get an available id
    MAIN_MENU "Please enter a valid option."
  fi
}

MAIN_MENU
