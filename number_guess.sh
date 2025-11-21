#!/bin/bash

# Connect to DB
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Check if user exists
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number
SECRET=$(( RANDOM % 1000 + 1 ))

echo "Guess the secret number between 1 and 1000:"

GUESS_COUNT=0

while true
do
  read GUESS

  # Validate integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((GUESS_COUNT++))

  # Compare numbers
  if (( GUESS < SECRET ))
  then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET ))
  then
    echo "It's lower than that, guess again:"
  else
    break
  fi
done

echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET. Nice job!"

# Update user stats
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")
IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"

if [[ -z $BEST_GAME || $GUESS_COUNT -lt $BEST_GAME ]]
then
  BEST_GAME=$GUESS_COUNT
fi

GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

UPDATE=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
