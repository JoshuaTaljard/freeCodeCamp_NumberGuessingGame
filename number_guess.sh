#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_VAL=$(($RANDOM%1000+1))
echo -e "\nRandom value: $RANDOM_VAL"

echo -e "\nEnter your username: "
read USERNAME_ENTRY

SEARCH_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME_ENTRY'")

if [[ -z $SEARCH_USERNAME ]];
then
  #log new user
  INSERT_NEW_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$SEARCH_USERNAME', 0, 0)")
  #set .env user information
  GAMES_PLAYED=0
  BEST_GAME=0
  #display new user
  echo -e "\nWelcome, $SEARCH_USERNAME! It looks like this is your first time here."
else
  # extract user information
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$SEARCH_USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$SEARCH_USERNAME'")
  # display existing user
  echo -e "\nWelcome back, $SEARCH_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

CURRENT_GAME=0

echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS
echo -e "\nuser guess is: $USER_GUESS"
string01='^[0-9]+$'

#user guesses the random value
while [[ $USER_GUESS -ne $RANDOM_VAL ]]
do
  echo loop started
  
  #if [[ $USER_GUESS != ^[0-9]+$ ]]; #check if intry is an integer
  if [[ ${USER_GUESS//[0-9]/} ]]; #check if intry is an integer
  then

    echo -e "\nThat is not an integer, guess again:"
    read USER_GUESS

  else

    if [[ $USER_GUESS > $RANDOM_VAL ]]; #guess is too high
    then
      echo -e "\nIt's lower than that, guess again:"
      read USER_GUESS
    elif [[ $USER_GUESS < $RANDOM_VAL ]]; #guess is too low
    then
      echo -e "\nIt's higher than that, guess again:"
      read USER_GUESS    
    else #guess is just right
      echo -e "\nNumber found."
    fi
    
  fi

  #increment tries counter
  CURRENT_GAME=$(($CURRENT_GAME+1))
done

#increment user games counter
GAMES_PLAYED=$((GAMES_PLAYED+1))
#set new 
if [[ $CURRENT_GAME > $BEST_GAME ]];
then
  #new best game
  #INSERT_GAME_STATS=$($PSQL "INSERT INTO users(games_played, best_game) VALUES('$GAMES_PLAYED', '$CURRENT_GAME') WHERE username='$USERNAME_ENTRY'")
  INSERT_GAME_STATS_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$SEARCH_USERNAME'")
  INSERT_GAME_STATS_BEST=$($PSQL "UPDATE users SET best_game=$CURRENT_GAME WHERE username='$SEARCH_USERNAME'")
else
  #old best game remains unchanged
  #INSERT_GAME_STATS_GAMES_ONLY=$($PSQL "UPDATE users SET best_game=")
  #do not update original best game (old record is was not beaten)
  echo -e "\nOLD RECORD NOT BEATEN FOR >>> $SEARCH_USERNAME"
fi

#print result
echo -e "\nYou guessed it in $CURRENT_GAME tries. The secret number was $RANDOM_VAL. Nice job!"
