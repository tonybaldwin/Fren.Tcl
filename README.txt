Fren.Tcl

a tcl/tk Friendika posting client
by Tony Baldwin | http://www.baldwinsoftware.com

This read me has almost nothing of value to tell you.
I hacked up this little thingy in a couple hours time.

It needs more work.

This is like version 0.1, or something.
Like an Alpha release.
I should seek funding on kickstarter and tease people with invites.
:P Diaspora*
HAHAHAHA!!!

Anyway, if anyone wants to hack on it, co0l.
Or use it, even.

This repo includes a bash script that pretty well does the same stuff,
only with curl, rather than tcl's http.
That would be frendi.sh

The tcl script, fren.tcl, will upvar the frentcl.conf file to set
variables, like your username:password and the server on which
you are friendika-ing, your preferred browser, etc.
If they are in the same dir, you're set.
For my part, I put the conf in ~/.frentcl.conf, but if you do that,
edit line 12 in fren.tcl to reflect that change.
Also, I made the save_as process choose ~/Documents/fposts to save
files, which is also where frendi.sh does that.
Feel free to alter that.

You can also post to a status.net installation with this thingy,
as well as post to friendika and status.net simultaneously, as well
as farcepork and tweeter.

There is information at baldwinsoftware.com/wiki on how to run tcl
programs on windows, but, I recommend running this on gnu/linux.

If you haven't the technological wherewithall to make either of these work
for yourself, you should probably just post from the web interface
for now, and wait until I (or some kind soul) rounds out this code.

Thanks for your support.

<3 <3 <4
x0x0x0x0x

./tony
http://friendika.dsn-test.com/profile/tonybaldwin
