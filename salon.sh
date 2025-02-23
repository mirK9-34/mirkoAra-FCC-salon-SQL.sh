#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Mostra i servizi disponibili
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")

  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do 
    echo "$SERVICE_ID) $NAME"
  done

  # Chiede il servizio all'utente
  read SERVICE_ID_SELECTED
  SERVICE_AVAILABILITY=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

  if [[ -z $SERVICE_AVAILABILITY ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # Chiede il numero di telefono
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    # Se il cliente non esiste, chiede il nome e lo registra
    if [[ -z $CUSTOMER_NAME ]]
    then 
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
    fi

    # Recupera CUSTOMER_ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    # Chiede l'orario dell'appuntamento
    echo -e "\nWhat time would you like your $SERVICE_AVAILABILITY, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Inserisce l'appuntamento nel database
    $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

    # Conferma l'appuntamento
    echo -e "\nI have put you down for a $SERVICE_AVAILABILITY at $SERVICE_TIME, $CUSTOMER_NAME."

    # Termina lo script
    exit 0
  fi
}

MAIN_MENU
