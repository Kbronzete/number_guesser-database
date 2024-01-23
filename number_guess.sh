#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo Enter your username:
read USERNAME
USER_INFO=$($PSQL "SELECT games_played, best_game FROM user_info WHERE username='$USERNAME'")
if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ADD_USER=true
else
  ADD_USER=false
  echo $USER_INFO | while IFS="|" read -r GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi
RANDOM_NUMBER=$((RANDOM % 1000 + 1))
echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_TRIES=0
GUESS=0
while [ $GUESS -ne $RANDOM_NUMBER ]
do
  read GUESS
  if [[ ! "$GUESS" =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  fi
  ((NUMBER_OF_TRIES++))
done
echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
if $ADD_USER
then
  ADD_USER_RESULT=$($PSQL "INSERT INTO user_info(username, best_game) VALUES('$USERNAME',$NUMBER_OF_TRIES)")
else
  echo $USER_INFO | while IFS="|" read -r GAMES_PLAYED BEST_GAME
  do
    if [[ $NUMBER_OF_TRIES -lt $BEST_GAME ]]
    then
      UPDATE_BEST_GAME=$($PSQL "UPDATE user_info SET best_game = $NUMBER_OF_TRIES WHERE username='$USERNAME'")
    fi
  done
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE user_info SET games_played = games_played + 1 WHERE username='$USERNAME'")
fi

  
