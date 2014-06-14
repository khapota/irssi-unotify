use strict;
use warnings;

# This is a common method of declaring package scoped variables before the
# 'our' keyword was boolroduced.  You should pick one form or the other, but
# generally speaking, the our $var is preferred in new code.

use vars qw($VERSION %IRSSI);

use Irssi;
use Net::DBus;

our $VERSION = '1.00';
our %IRSSI = (
  authors     => 'khapota',
  contact     => 'phantrongkhanh87@gmail.com',
  name        => 'Irssi Ubuntu Notification',
  description => 'Send notification to Ubuntu Notification System via dbus',
  license     => 'GPL',
);

#if enable is OFF, nothing to be notified
my $enable;
#if set public_msg to ON, all message will be notified
#if set public_msg to OFF, only message that contain mention string and private message are notified
my $public_msg;
#mention string, message still be notified if it contain this tring
my $mention_str;
my $dcc_msg;

Irssi::settings_add_bool("unotify", "unotify_enable", 1);
Irssi::settings_add_bool("unotify", "unotify_public_msg", 1);
Irssi::settings_add_bool("unotify", "unotify_dcc_msg", 1);
Irssi::settings_add_str("unotify", "unotify_mention_str", 1);

$enable = Irssi::settings_get_bool('unotify_enable');
$dcc_msg = Irssi::settings_get_bool('unotify_dcc_msg');
$public_msg = Irssi::settings_get_bool('unotify_public_msg');
$mention_str = Irssi::settings_get_str('unotify_mention_str');

#get new config value
Irssi::signal_add('setup changed', \&reload_settings);
#public message function
Irssi::signal_add('message public', 'received_public_msg');
#privite message function
Irssi::signal_add('message private', 'received_private_msg');
#dcc request function
Irssi::signal_add('dcc request', 'dcc_request');

#loaded message
send_bus_signal_to_notification_server("Irssi", "UNotify script is loaded");

sub reload_settings {
  $enable = Irssi::settings_get_bool('unotify_enable');
  $dcc_msg = Irssi::settings_get_bool('unotify_dcc_msg');
  $public_msg = Irssi::settings_get_bool('unotify_public_msg');
  $mention_str = Irssi::settings_get_str('unotify_mention_str');
}

sub send_bus_signal_to_notification_server {
  if (!$enable) {
    return;
  }
  my ($summary, $message) = @_;
  my $appname = 'Irssi';
  my $bus = Net::DBus->session;
  my $notifications = $bus->get_service('org.freedesktop.Notifications');
  my $object = $notifications->get_object('/org/freedesktop/Notifications',
    'org.freedesktop.Notifications');
  $object->Notify("$appname",
    0,
    "$ENV{'HOME'}/.irssi/irssi.png",
    "$summary",
    "$message",
    [], { "append" => "allowed" }, -1);
}

sub received_private_msg {
  my ($server, $msg, $nick_addr, $target) = @_;
  $nick_addr = "[private] " . $nick_addr;
  send_bus_signal_to_notification_server($nick_addr, $msg);
}

sub received_public_msg {
  if (!$public_msg && $mention_str eq "") {
    return;
  }
  my ($server, $msg, $nick, $nick_addr, $target) = @_;
  if (index($msg, $mention_str) == -1 && !$public_msg) {
    return;
  }
  #create setting for channel that do not want to get msg
  my $title = $nick . " in " . $target;
  send_bus_signal_to_notification_server($title, $msg);
}

sub dcc_request {
  if (!$dcc_msg) {
    return;
  }
  my ($dcc, $send_address) = @_;
  $send_address = "[dcc]" . $send_address;
  send_bus_signal_to_notification_server($send_address, $dcc->{arg});
}
