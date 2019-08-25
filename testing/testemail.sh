#!/bin/bash -xv

# Auxiliary set of extra functions used in other scripts of the RACS pipeline.                            
#                                                
# Main functions included:
#       - emailme(): function to notify the user by sending an email.
#
#########################


emailme() {
# function to send emails, uses 3 arguments:
#   arg.1: subject
#   arg.2: message
#   arg.3: email address (optional), otherwise it will attempt to read it from the "RACS.config" file
#
# ** DISCLAIMER **
# This functionality requires to have an emailer program --such as, "mail" or #
# "sendmail"-- properly installed and configured to work. 
#
#######

	# file from where to read email address
	configFile="RACS.config"

	# if config.file is found will read target email address from there
	[ -f $configFile ] && fromfile=`head $configFile` || fromfile=""
	# otherwise attempt to use the 3rd argument
	To=${3:-"$fromfile"}

	# arg.1 = subject
	Subject=$1

	# arg.2 = message
	Msg=$2

	# detect mailer program
	MAILER=""
	# check whether 'mail' or 'sendmail' are available in the system
	mailers="mail sendmail"
	for cmd in $mailers; do
		#echo $cmd;
		if command -v $cmd; then
			MAILER=$cmd;
			echo "Using '$MAILER' as mailer program... in $HOSTNAME"
			break;
		fi;
	done

	# check whether there is an program for sending emails...	
	[[ -z "$MAILER" ]] && echo "An email server and mailer program such as '$mailers' should be configured in this sever ($HOSTNAME) for this functionality to work!!"


	# check that there is a emailer configured and fields of the email are not empty
 	if [ "$MAILER" != "" ] &&  [ "$To" != "" ] && [ "$Subject" != "" ] ;
	then
		# send email...
		echo "POS: " $MAILER $Subject $To
		echo "hello world" | $MAILER -s $Subject $To
	else
		echo "neg: " $MAILER $Subject $To
	fi
}


emailme test
