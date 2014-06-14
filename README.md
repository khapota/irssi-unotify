Irssi Ubuntu Notification
=========================
Irssi Notify via DBus (using notify-osd)
Hint: append => allowed

Support:

- Public message

- Mention string

- Dcc event

Dependency:

Ubuntu notify-osd

Perl Net::DBus module

Todo:

- Option: Disable public message in one or some channel

- Option: allow two or more mention strings

Install
=======

Install Net::DBus module

sudo apt-get install libnet-dbus-perl


or via CPAN:

sudo perl -MCPAN -e "install Net::DBus"


Copy Irssi icon to $HOME/.irssi

Copy script unotify.pl to $HOME/.irssi/scripts


In Irssi run:

/script load unotify

Setting
=======
Disable all notification

/set unotify_enable OFF


Disable all public message notification

/set unotify_public_msg OFF

/set unotify_mention_str ""


Disable all public message except the messages that contain mention
string

/set unotify_public_msg OFF

/set unotify_mention_str "your_nick"

Reference
=========
The ideal belong to: 

https://code.google.com/p/irssi-libnotify/

I just change somethings

- setting

- "append" hint

- mention string

- remove 'print text' signal
