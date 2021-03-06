# This code was forked from the LiveJournal project owned and operated
# by Live Journal, Inc. The code has been modified and expanded by
# Dreamwidth Studios, LLC. These files were originally licensed under
# the terms of the license supplied by Live Journal, Inc, which can
# currently be found at:
#
# http://code.livejournal.org/trac/livejournal/browser/trunk/LICENSE-LiveJournal.txt
#
# In accordance with the original license, this code and all its
# modifications are provided under the GNU General Public License.
# A copy of that license can be found in the LICENSE file included as
# part of this distribution.

package LJ::Console::Command::ResetEmail;

use strict;
use base qw(LJ::Console::Command);
use Carp qw(croak);

sub cmd { "reset_email" }

sub desc { "Resets the email address of a given account. Requires priv: reset_email." }

sub args_desc { [
                 'user' => "The account to reset the email address for.",
                 'value' => "Email address to set the account to.",
                 'reason' => "Reason for the reset",
                 ] }

sub usage { '<user> <value> <reason>' }

sub can_execute {
    my $remote = LJ::get_remote();
    return $remote && $remote->has_priv( "reset_email" );
}

sub execute {
    my ($self, $username, $newemail, $reason, @args) = @_;

    return $self->error("This command takes three arguments. Consult the reference.")
        unless $username && $newemail && $reason && scalar(@args) == 0;

    my $u = LJ::load_user($username);
    return $self->error("Invalid user $username")
        unless $u;

    $u->reset_email( $newemail, \ my $update_err, \ my $esucc );
    return $self->error( $update_err ) if $update_err;
    $self->info( "Confirmation email could not be sent." ) unless $esucc;

    my $remote = LJ::get_remote();
    LJ::statushistory_add($u, $remote, "reset_email", $reason);

    return $self->print("Email address for '$username' reset.");
}

1;
