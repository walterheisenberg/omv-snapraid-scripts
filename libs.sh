#!/bin/bash

# An wen soll die Nachricht gesendet werden
MAIL=triple.x@web.de

# Default Werte
FROM="Hoppetz Status-Report Default"
FROMMAIL="triple.x@web.de"

# Logging Settings
SYSLOG="true"            # activate write to syslog (default="true")
VERBOSE="false"            # use the verbose mode, with additional info on the command line (default="true")
LOGGER="/usr/bin/logger"   # path and name of logger (default="/usr/bin/logger")
FACILITY="local5"         # facility to log to -> see syslog.conf  and add the line (default="local6")
						# "local6.* %/var/log/autoshutdown.log"



################################################################
#
#   name:	_send_email
#   parameter : 	# $1 = Betreff
					# $2 = Datei mit Mailtext
					# Optional:
					# $3 = Von wem wurde die Nachricht gesendet (Voller Name), z.B. "Server Status-Report"
					# $4 = Antwort an Mail-Adresse
#   return: 	0 = Alles OK
#				1 = Fehler passiert
#
_send_email(){

case "$#" in
	0|1|3)
			_log "WARN: Mail konnte nicht gesendet werden. Fehlende Parameter!"
			return 1
			;;

	2)
			mail -s "$1" -a 'Content-Type: text/plain; charset=utf-8' $MAIL -- -F "$FROM" -f "$FROMMAIL" < $2

			if [ $? -eq 0 ]; then
				_log "INFO: Status Report an $MAIL gesendet"
				return 0
			else
				_log "WARN: Mail konnte nicht gesendet werden. Es ist ein Fehler aufgetreten. Siehe /var/log/mail.log"
				return 1
			fi
			;;

	4)
			mail -s "$1" -a 'Content-Type: text/plain; charset=utf-8' $MAIL -- -F "$3" -f "$4" < $2

			if [ $? -eq 0 ]; then
				_log "INFO: Status Report an $MAIL gesendet"
				return 0
			else
				_log "WARN: Mail konnte nicht gesendet werden. Es ist ein Fehler aufgetreten. Siehe /var/log/mail.log"
				return 1
			fi
			;;
esac
}

################################################################
#
#   name      : _log
#   parameter   : $LOGMESSAGE : logmessage in format "PRIORITY: MESSAGE"
#   return      : none
#
_log()
   {(


       [[ "$*" =~ ^([A-Za-z]*):(.*) ]] &&
         {
            PRIORITY=${BASH_REMATCH[1]}
            LOGMESSAGE=${BASH_REMATCH[2]}
            [[ "$(basename "$0")" =~ ^(.*)\. ]] && LOGMESSAGE="${BASH_REMATCH[1]}[$$]: $PRIORITY: '$LOGMESSAGE'";
         }

      if $VERBOSE ; then
         # next line only with implementation where logger does not support option '-s'
         # echo "$(date '+%b %e %H:%M:%S'):$LOGMESSAGE"

         [ $SYSLOG ] && $LOGGER -s -t "$(date '+%b %e %H:%M:%S'): $USER" -p $FACILITY.$PRIORITY "$LOGMESSAGE"

      else
         [ $SYSLOG ] && $LOGGER -p $FACILITY.$PRIORITY "$LOGMESSAGE"

      fi   # > if [ "$VERBOSE" = "NO" ]; then

   )}

