#!/bin/bash


printFSTable(){
	echo -e "\n"
	df -Th -x procfs -x tmpfs -x devtmpfs -x sysfs
	echo -e "\n"
}


mountFileSystem(){
	echo -e "\n"
	echo -e "Введите путь до устройства или файла"
	read -r answer
	if [[ -z "$answer" ]] || [[ ! -e "$answer" ]] then
		echo "Ошибка! Файл с таким именем не существует" >&2
		return
	fi


	read -r -p "Введите каталог монтирования > " answer2
	if [[ ! -e "$answer2" ]] then 
		mkdir "$answer2"
	fi


	if [[ -d "$answer2" ]] && [[ "$(ls -A "$answer2" 2> /dev/null)" == "" ]] && [[ -f "$answer" ]] then 
		dd if=/dev/zero of="$answer" bs=1M count=10
		TMP1=$(losetup --find --show "$answer")
		mkfs -t ext4 "$TMP1"
		mount "$TMP1" "$answer2"
	elif [[ -d "$answer2" ]] && [[ "$(ls -A "$answer2" 2> /dev/null)" == "" ]] && [[ ! -d "$answer" ]] then
		mkfs -t ext4 "$answer"
		mount "$answer" "$answer2"
	else 
		echo -e "Каталог не пустой" >&2
		return
	fi
	
	
}


umountFileSys(){
	echo -e "\n"
	readarray -t menu < <(df -Th -x procfs -x tmpfs -x devtmpfs -x sysfs | tail -n +6 | cut -d ' ' -f 1)
	menu+=(Справка Назад)
	PS3="Выберите файловую систему, которую хотите отмонтировать или введите путь до неё > "
	select ans in "${menu[@]}"; do
		case $ans in 
			Справка)
				echo -e "\nВ этом разделе вы можете выбрать, какую файловую систему отмонтировать\n"
				;;
			Назад)
				break
				;;
			*)
				if [[ -z $ans ]]; then 
					if [[ " ${menu[*]} " =~ " ${REPLY} " ]]; then 
						umount $REPLY
						losetup --detach $REPLY
						break
					fi
					echo -e "Ошибка! Некорректный ввод\n" >&2
					break
				else
					umount $ans
					losetup --detach $ans
					break
				fi
				;;
		esac
	done
}


changeSettings(){
	readarray -t menu1 < <(df -Th -x procfs -x tmpfs -x devtmpfs -x sysfs | tail -n +6 | cut -d ' ' -f 1)
	menu1+=(Справка Назад)
	PS3="Введите номер файловой системы, настройки которой хотите изменить > "
	select ans1 in "${menu1[@]}"; do
		case $ans1 in 
			Справка)
				echo -e "\nВ этом разделе вы можете поменять настройки для выбранной файловой системы\n"
				;;
			Назад)
				break
				;;
			*)
				if [[ -z $ans1 ]]; then 
					echo -e "Ошибка! Некорректный ввод\n" >&2
					break
				else
					PS3="Выберите режим, в который хотите перевести файловую систему > "
					select ans11 in "Перевести файловую систему в режим \"только для чтения\"" "Перевести файловую систему в режим \"чтение и запись\"" "Справка" "Назад"; do
						case $ans11 in
							Справка)
								echo -e "Введите номер желаемого режима без скобки\n"
								;;
							Назад)
								break
								;;
							"Перевести файловую систему в режим \"только для чтения\"")
								mount -o remount,ro $(df --output=target $ans1 | tail -n +2)
								break
								;;
							"Перевести файловую систему в режим \"чтение и запись\"")
								mount -o remount,rw $(df --output=target $ans1 | tail -n +2)
								break
								;;
							*)
								echo -e "Ошибка! некорректный ввод\n" >&2
								break
								;;
						esac
					done
				fi
				PS3="Введите номер файловой системы, настройки которой хотите изменить > "
				break
				;;
		esac
		REPLY=
	done
}


printParametres(){
	readarray -t menu2 < <(df -Th -x procfs -x tmpfs -x devtmpfs -x sysfs | tail -n +6 | cut -d ' ' -f 1)
	menu2+=(Справка Назад)
	PS3="Введите номер файловой системы, параметры которой хотите увидеть > "
	select ans2 in "${menu2[@]}"; do
		case $ans2 in 
			Справка)
				echo -e "\nВ этом разделе вы можете увидеть параметры выбранной файловой системы\n"
				;;
			Назад)
				break
				;;
			*)
				if [[ -z $ans2 ]]; then 
					echo -e "Ошибка! Некорректный ввод\n" >&2
					break
				else
					mount | grep $(df --output=target $ans2 | tail -n +2)
					echo -e "\n"
				fi
				break
				;;
		esac
	done
}


extFSInfo(){
	readarray -t menu3 < <(mount | grep -e "ext.")
	menu3+=(Справка Назад)
	PS3="Введите номер файловой системы, информацию о которой хотите увидеть > "
	select ans3 in "${menu3[@]}"; do
		case $ans3 in 
			Справка)
				echo -e "\nВ этом разделе вы можете увидеть информацию о выбранной файловой системе\n"
				;;
			Назад)
				break
				;;
			*)
				if [[ -z $ans3 ]]; then 
					echo -e "Ошибка! Некорректный ввод\n" >&2
					break
				else
					tune2fs -l $(echo "$ans3" | cut -d ' ' -f 1)
				fi
				break
				;;
		esac
	done
}


if [[ "$2" != "" ]];
then
	echo "usage: ./file_sys_management.sh [--help]" >&2
	exit
fi

case "$1" in
	--help)
		echo "Этот сценарий позволяет работать с файловыми системами"
		exit
		;;
esac

if [[ "$1" != "" ]];
then
	echo "usage: ./file_sys_management.sh [--help]" >&2
	exit
fi

echo -e "\nС помощью данной программы вы можете управлять файловыми системами.\n\nРазработчик: Панков Дмитрий Евгеньевич, группа Б20-505\n\n"
echo -e "Главное меню:\n"
PS3="> "

select answer in "Вывести таблицу файловых систем" "Монтировать файловую систему" "Отмонтировать файловую систему" "Изменить параметры монтирования примонтированной файловой системы" "Вывести параметры монтирования примонтированной файловой системы" "Вывести детальную информацию о файловой системе ext*" "Справка" "Выход"; do
	case $answer in 
		Выход)
		       	break
			;;
		"Вывести таблицу файловых систем")
			printFSTable
			;;
		"Монтировать файловую систему")
			mountFileSystem
			;;
		"Отмонтировать файловую систему")
			umountFileSys
			PS3="> "
			;;
		"Изменить параметры монтирования примонтированной файловой системы")
			changeSettings
			PS3="> "
			;;
		"Вывести параметры монтирования примонтированной файловой системы")
			printParametres
			PS3="> "
			;;
		"Вывести детальную информацию о файловой системе ext*")
			extFSInfo
			PS3="> "
			;;
		Справка)
			echo -e "В данном меню можно выбрать действие с файловой системой\n"
			;;
		*)
			echo -e "\nОшибка! Введите номер пункта без скобки" >&2
			;;
	esac
	
	echo -e "--------------------------------------------------\n"
	echo -e "Главное меню:\n"
	REPLY=
done
