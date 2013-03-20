#!/usr/bin/env perl
#
# Add or remove (drain or undrain) nodes on Zeus/Riverbed ZXTM load balancer in a specific site.
# Tom Molin, 2011-06-22
use Getopt::Long;
use SOAP::Lite 0.60;
# Soap Dependencies:
# perl-Authen-SASL-2.13-1.el5.rf.noarch.rpm         perl-Net-Jabber-2.0-1.2.el5.rf.noarch.rpm  perl-XML-Stream-1.23-1.el5.rf.noarch.rpm
# perl-Email-Date-Format-1.002-1.el5.rf.noarch.rpm  perl-Net-XMPP-1.02-1.el5.rf.noarch.rpm
# perl-MIME-Lite-3.027-1.el5.rf.noarch.rpm          perl-SOAP-Lite-0.71-1.el5.rf.noarch.rpm



GetOptions (    "node=s"	=> \$NODE,						# --node=[IP-Addr:Port]
		"pool=s"	=> \$POOL,						# --pool=[pool]
		"action=s"	=> \$ACTION );						# --action=[drain/undrain]

chomp $NODE;
chomp $ACTION;

die "Please specify --node=[node] and --pool=[pool] and --action=[drain/undrain]"
        if ( $NODE eq "" && $ACTION eq "" );

# At the moment all nodes is balanced from both sites, but this may be changed in the future.
# Add any new nodes to one or both of A and B sites nodelists. List in format ("ip1:port","ip2:port","ipN:port")
my @MMONodes=("10.75.80.31:8080","10.75.80.32:8080","10.75.80.31:8060","10.75.80.32:8060");
my @MMONodes=("");
my @STONodes=("");

if ( $POOL ne "www.stage.svtplay.se" )
{
	$POOL = www.stage.svt.se";
} 
chomp $POOL;

 foreach (@MMONodes) {
 	if ( $_ eq $NODE ) {
    	# Do Action for node
    	print "$ACTION"."ing $NODE from Loadbalancer\n";
	# This is the url of the Stage Stingray admin server
	my $admin_server = 'https://USER:PW@IP:Port';

	# The virtual server to edit, and the rule to enable
	my $poolName = $POOL;
	my $nodeName = $NODE;

	my $conn = SOAP::Lite
	   -> ns('http://soap.zeus.com/zxtm/1.0/Pool/')
	   -> proxy("$admin_server/soap")
	   -> on_fault( sub  {
	         my( $conn, $res ) = @_;
	         die ref $res ? $res->faultstring :
	             $conn->transport->status; } )
	   ->readable(1);

        if ( $ACTION eq "drain" ) {
        	$conn->addDrainingNodes( [ $poolName ], [ [ $nodeName ] ] );
        	print "Drained $NODE from the load balancer.\n";
        }
        if ( $ACTION eq "undrain" )
	{
        	$conn->removeDrainingNodes( [ $poolName ], [ [ $nodeName ] ] );
        	print "Undrained $NODE from the load balancer.\n";
    	}
 	}
}
