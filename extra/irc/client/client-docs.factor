USING: help.markup help.syntax quotations kernel irc.messages ;
IN: irc.client

HELP: irc-client "IRC Client object" ;

HELP: irc-server-chat "Chat for server messages unmanaged by other chats" ;

HELP: irc-channel-chat "Chat for irc channels" ;

HELP: irc-nick-chat "Chat for irc users" ;

HELP: irc-profile "IRC Client profile object" ;

HELP: connect-irc "Connecting to an irc server"
{ $values { "irc-client" "an irc client object" } }
{ $description "Connects and logins " { $link irc-client } " using the settings specified on its " { $link irc-profile } "." } ;

HELP: attach-chat "Chatting with irc channels/users/etc"
{ $values { "irc-chat" "an irc chat object" } { "irc-client" "an irc client object" } }
{ $description "Registers " { $snippet "irc-chat" } " with " { $snippet "irc-client" } " and starts listening." } ;

HELP: detach-chat "Stop an unregister chat"
{ $values { "irc-chat" "an irc chat object" } }
{ $description "Unregisters " { $snippet "irc-chat" } " from " { $snippet "irc-client" } " and stops listening. This is how you part from a channel." } ;

HELP: terminate-irc "Terminates an irc client"
{ $values { "irc-client" "an irc client object" } }
{ $description "Terminates all activity by " { $link irc-client } " cleaning up resources and notifying chats." } ;

HELP: speak "Sends a message through a chat"
{ $values { "message" "a string or irc message object" } { "irc-chat" "an irc chat object" } }
{ $description "Sends " { $snippet "message" } " through " { $snippet "irc-chat" } ". Strings are automatically promoted to privmsg objects." } ;

HELP: hear "Reads a message from a chat"
{ $values { "irc-chat" "an irc chat object" } { "message" "an irc message object" } }
{ $description "Reads " { $snippet "message" } " from " { $snippet "irc-chat" } "." } ;

ARTICLE: "irc.client" "IRC Client"
"An IRC Client library"
{ $heading "IRC objects:" }
{ $subsection irc-client }
{ $heading "Chat objects:" }
{ $subsection irc-server-chat }
{ $subsection irc-channel-chat }
{ $subsection irc-nick-chat }
{ $heading "Setup objects:" }
{ $subsection irc-profile }
{ $heading "Words:" }
{ $subsection connect-irc }
{ $subsection terminate-irc }
{ $subsection attach-chat }
{ $subsection detach-chat }
{ $subsection hear }
{ $subsection speak }
{ $heading "IRC messages" }
"Some of the RFC defined irc messages as objects:"
{ $table
  { { $link irc-message } "base of all irc messages" }
  { { $link logged-in } "logged in to server" }
  { { $link ping } "ping message" }
  { { $link join } "channel join" }
  { { $link part } "channel part" }
  { { $link quit } "quit from irc" }
  { { $link privmsg } "private message (to client or channel)" }
  { { $link kick } "kick from channel" }
  { { $link roomlist } "list of participants in channel" }
  { { $link nick-in-use } "chosen nick is in use by another client" }
  { { $link notice } "notice message" }
  { { $link mode } "mode change" }
  { { $link unhandled } "uninmplemented/unhandled message" }
  }
{ $heading "Special messages" }
"Some special messages that are created by the library and not by the irc server."
{ $table
  { { $link irc-chat-end } "sent to a chat when it has been detached from the client, the chat should stop after it receives this message. " }
  { { $link irc-end } " sent when the client isn't running anymore, chats should stop after it receives this message." }
  { { $link irc-disconnected } " sent to notify chats that connection was lost." }
  { { $link irc-connected } " sent to notify chats that a connection with the irc server was established." } }

{ $heading "Example:" }
{ $code
  "USING: irc.client ;"
  "SYMBOL: bot"
  "SYMBOL: mychannel"
  "! Create the profile and client objects"
  "\"irc.freenode.org\" irc-port \"mybot123\" f <irc-profile> <irc-client> bot set"
  "! Connect to the server"
  "bot get connect-irc"
  "! Create a channel chat"
  "\"#mychannel123\" <irc-channel-chat> mychannel set"
  "! Register and start chat (this joins the channel)"
  "mychannel get bot get attach-chat"
  "! Send a message to the channel"
  "\"what's up?\" mychannel get speak"
  "! Read a message from the channel"
  "mychannel get hear"
}
  ;

ABOUT: "irc.client"
