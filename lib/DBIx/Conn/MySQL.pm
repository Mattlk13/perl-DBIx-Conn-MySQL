package DBIx::Conn::MySQL;

# DATE
# VERSION

use strict;
use warnings;

sub import {
    require DBIx::Connect::MySQL;

    my $pkg  = shift;

    my $dsn;
    die "import(): Please supply at least a database name" unless @_;
    if ($_[0] =~ /=/) {
        $dsn = "DBI:mysql:".shift;
    } else {
        $dsn = "DBI:mysql:database=".shift;
    }

    my $var = 'dbh';
    if (@_ && $_[0] =~ /\A\$(\w+)\z/) {
        $var = $1;
        shift;
    }

    my $user; $user = shift if @_;
    my $pass; $pass = shift if @_;

    my $dbh = DBIx::Connect::MySQL->connect($dsn, $user, $pass);

    my $caller = caller();
    {
        no strict 'refs';
        no warnings 'once';
        *{"$caller\::$var"} = \$dbh;
    }
}

1;
# ABSTRACT: Shortcut to connect to MySQL database

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

In the command-line, instead of:

 % perl -MDBI -E'my $dbh = DBI->connect("dbi:mysql:database=mydb", "someuser", "somepass"); $dbh->selectrow_array("query"); ...'

or:

 % perl -MDBIx::Connect::MySQL -E'my $dbh = DBI->connect("dbi:mysql:database=mydb"); $dbh->selectrow_array("query"); ...'

you can just:

 % perl -MDBIx::Conn::MySQL=mydb -E'$dbh->selectrow_array("query"); ...'

To connect with some L<DBD::mysql> parameters:

 % perl -MDBIx::Conn::MySQL='database=mydb;host=192.168.1.10;port=23306' -E'$dbh->selectrow_array("query"); ...'

To change the exported database variable name from the default '$dbh'

 % perl -MDBIx::Conn::MySQL=mydb,'$handle' -E'$handle->selectrow_array("query"); ...'

To supply username and password:

 % perl -MDBIx::Conn::MySQL=mydb,myuser,mysecret -E'$handle->selectrow_array("query"); ...'


=head1 DESCRIPTION

This module offers some saving in typing when connecting to a MySQL database
using L<DBI>, and is particularly handy in one-liners. First, it uses
L<DBIx::Connect::MySQL> to connect so you don't have to supply username and
password if you have configuration file (e.g. F<~/.my.cnf>); that module will
search the username and password from configuration files.

Second, it automatically C<connect()> and exports the database handle C<$dbh>
for you.

You often only have to specify the database name in the import argument:

 -MDBIx::Conn::MySQL=mydb

This will result in the following DSN:

 DBI:mysql:database=mydb

If you need to specify other parameters in the DSN, e.g. when the C<host> is not
C<localhost>, or the C<port> is not the default port, you can specify that in
the first import argument too (note the quoting because the shell will interpret
C<;> as command separator). When the first import argument contains C<=>, the
module knows that you want to specify DSN parameters:

 -MDBIx::Conn::MySQL='mydb;host=192.168.1.10;port=23306'

this will result in the following DSN:

 'DBI:mysql:database=mydb;host=192.168.1.10;port=23306

If you want to use another variable name other than the default C<$dbh> for the
database handle, you can specify this in the second import argument (note the
quoting because otherwise the shell will substitute with shell variable):

 -MDBIx::Conn::MySQL=mydb,'$handle'

Lastly, if you want to supply username and password anyway, you can do that via
the third and fourth import arguments (or the second and third import arguments,
as long as the username does not begin with C<$>):

 -MDBIx::Conn::MySQL=mydb,'$handle',myuser,mysecret
 -MDBIx::Conn::MySQL=mydb,myuser,mysecret

But note that specifying passwords on the command-line is not recommended (hence
the use of DBIx::Connect::MySQL in the first place).
