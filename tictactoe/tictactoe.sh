#!/bin/bash

BOARD=(1 2 3 
       4 5 6 
       7 8 9)

current_player="Player2"
mode="computer"

function _show_board() {
	clear
	for i in {1..9}
	do
		if (($i % 3)); then
			echo -n "  ${BOARD[$i-1]}  "
		else
			echo -e "  ${BOARD[$i-1]}\n"
		fi
	done
}

function _change_player() {
	if [ $current_player = "Player1" ]; then
		current_player="Player2"
		echo "Now it's $current_player turn"
	else
		current_player="Player1"
		echo "Now it's $current_player turn"
	fi
}

function _check_win()
{
	
	is_win=0
	draw=1
	for i in "X" "O"
	do
		if [ ${BOARD[0]} = $i ] && [ ${BOARD[1]} = $i ] && [ ${BOARD[2]} = $i ]; then
			is_win=1
		fi

		if [ ${BOARD[3]} = $i ] && [ ${BOARD[4]} = $i ] && [ ${BOARD[5]} = $i ]; then
			is_win=1
		fi
		
		if [ ${BOARD[6]} = $i ] && [ ${BOARD[7]} = $i ] && [ ${BOARD[8]} = $i ]; then
			is_win=1
		fi
		
		
		
		if [ ${BOARD[0]} = $i ] && [ ${BOARD[3]} = $i ] && [ ${BOARD[6]} = $i ]; then
			is_win=1
		fi

		if [ ${BOARD[1]} = $i ] && [ ${BOARD[4]} = $i ] && [ ${BOARD[7]} = $i ]; then
			is_win=1
		fi
		
		if [ ${BOARD[2]} = $i ] && [ ${BOARD[5]} = $i ] && [ ${BOARD[8]} = $i ]; then
			is_win=1
		fi
		
		
		
		if [ ${BOARD[0]} = $i ] && [ ${BOARD[4]} = $i ] && [ ${BOARD[8]} = $i ]; then
			is_win=1
		fi
		
		if [ ${BOARD[2]} = $i ] && [ ${BOARD[4]} = $i ] && [ ${BOARD[6]} = $i ]; then
			is_win=1
		fi


		if [ $is_win -eq 1 ]; then
			if [ $current_player = "Player1" ]; then
				_show_board
				echo "Player1 won!"
				exit 0
			else
			       	_show_board	
				echo "Player2 won!"
				exit 0
			fi
		fi		
	done
	
	for i in {0..8}
	do
		if [ ${BOARD[$i]} == "O" ] || [ ${BOARD[$i]} == "X" ];then
			draw=1
		else
			draw=0
			break
		fi
	done
	if [ $draw -eq 1 ];then
		echo "DRAW!"
		exit 0
	fi
}

function _set_point() {
	
	if [ $current_player = "Player1" ]; then
		BOARD[$1-1]="X"
	else
		BOARD[$1-1]="O"
	fi

}

function _save_game() {
	printf "%s\n" "${BOARD[@]}" > save_game
	printf "$current_player\n" >> save_game
	printf "$mode\n" >> save_game
}

function _load_game() {
	counter=0
	BOARD=()
	while IFS= read -r line;
	do
		echo "$counter $line"
		if [ $counter -eq 9 ];then
			current_player=($line)
		elif [ $counter -eq 10 ];then
			mode=($line)
			break
		else	
			BOARD+=("$line")
		fi
		((counter++))
	done < save_game

}

function _computer() {
	
	while [ 1 ]
	do
		number=$((1 + $RANDOM % 9))
		echo "${BOARD[$number-1]}"
		if [ ${BOARD[$number-1]} != "O" ] && [ ${BOARD[$number-1]} != "X"  ]; then
			echo "$number"
			_set_point "$number"
			break
		fi
	done
}

function choose_mode() {
	
	FILE=save_game
	if [ -f "$FILE" ];then
		echo -n "Load the last saved game? (yes/no) "
		read answer
		if [ $answer == "yes" ]; then
			_load_game
			_change_player
			main
		fi
	fi


	while [ 1 ]
	do	
		echo -n "Would you like to play with user or computer? Accepted values: \"user\" or \"computer\" "
		read answer1
		if [ $answer1 == "user" ] || [ $answer1 == "computer" ]; then
			mode=$answer1
			break
		fi
	done
	main	
}

function main() {
	while [ 1 ]
	do
		_show_board
		_change_player

		if [ $mode == "computer" ] && [ $current_player == "Player2" ]; then
			_computer
		else
			while [ 1 ]
			do
	
				echo -n "Enter the field number (1..9) or save game (save): "
				read value
							
				if [ $value = "save" ]; then
					_save_game
					exit 0
				fi
				echo -n "Trying to select field number ${value}... "
				if [[ $value =~ ^[1-9]$ ]] && [ ${BOARD[$value-1]} != "O" ] && [ ${BOARD[$value-1]} != "X"  ]; then
					_set_point "$value"
					break
				else
					echo "FAILED!"
				fi
			done
		fi	
		_check_win
	done
}

choose_mode

