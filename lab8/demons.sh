#!/bin/bash


systemServiceSearch(){
	echo -e "\n"
	echo -e "Введите имя службы или его часть"
	read -r answer
	echo -e "\n"

	systemctl list-unit-files | grep "$answer"
}

showSystemdProc(){
	ps xawf -eo pid,user,cgroup | grep ".service$"
}

serviceManagement(){
	IFS=$'\n' read -r -d '' -a arr < <(systemctl list-units --type=service | head -n-6 | tail -n+2 cut -c 3- | cut -d" " -f 1 && printf '\0')
	makelist arr "Номер сервиса: "
	num=$?
	echo "==========" $num
	if [ $num -eq 0 ]; then
		return
	fi
	service=${arr[num-1]}
	options2=(
		"Включить службу"
		"Отключить службу"
		"Запустить/перезапустить службу"
		"Остановить службу"
		"Вывести содержимое юнита службы"
		"Отредактировать юнит службы"
		"Назад"
	)
	select opt in "${options2[@]}"; do
		case $opt in
			"Включить службу")
				systemctl enable "$service"
				break
				;;
			"Отключить службу")
				systemctl disable "$service"
				break
				;;
			"Запустить/перезупустить службу")
				systemctl restart "$service"
				break
				;;
			"Остановить службу")
				systemctl stop "$service"
				break
				;;
			"Вывести содержимое юнита службы")
				less "$(systemctl status $service | head -n+2 | tail -n-1 | cut -f2 -d "(" | cut -f1 -d ";")"
				break
				;;
			"Отредактировать юнит службы")
				vim "$(systemctl status $service | head -n+2 | tail -n-1 | cut -f2 -d "(" | cut -f1 -d ";")"
				break
				;;
			"Назад")
				return
				;;
			*)
				echo "Ошибка! Неверный ввод" >&2
				break
		esac
	done
}

searchEvent(){
	read -p "Введите имя службы -> " serv
	read -p "Введите степень важности -> " priority
	read -p "Строка поиска -> " request
	journalctl -p "$priority" -u "$service" -g "$request"
}

if [ "$EUID" -ne 0 ]; then
	echo "You need to be root to use this script"
	exit
fi
if [[ "$2" != "" ]];
then
	echo "usage: ./demons.sh [--help]" >&2
	exit
fi

case "$1" in
	--help)
		echo "Этот сценарий позволяет управлять системными службами и журналами"
		exit
		;;
esac

if [[ "$1" != "" ]];
then
	echo "usage: ./demons.sh [--help]" >&2
	exit
fi

echo -e "\nС помощью данной программы вы можете управлять системными службами и журналами.\n\nРазработчик: Панков Дмитрий Евгеньевич, группа Б20-505\n\n"
echo -e "Главное меню:\n"
PS3="> "

select answer in "Поиск системных служб" "Вывести список процессов и связанных с ними systemd служб" "Управление службами" "Поиск событий в журнале" "Справка" "Выход"; do
	case $answer in 
		Выход)
		       	break
			;;
		"Поиск системных служб")
			systemServiceSearch
			PS3="> "
			;;
		"Вывести список процессов и связанных с ними systemd служб")
			showSystemdProc
			PS3="> "
			;;
		"Управление службами")
			serviceManagement
			PS3="> "
			;;
		"Поиск событий в журнале")
			searchEvent	
			PS3="> "
			;;
		Справка)
			echo -e "В данном меню можно выбрать действие со службой либо журналом\n"
			;;
		*)
			echo -e "\nОшибка! Введите номер пункта без скобки" >&2
			;;
	esac
	
	echo -e "--------------------------------------------------\n"
	echo -e "Главное меню:\n"
	REPLY=
done
