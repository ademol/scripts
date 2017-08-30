#!/usr/bin/perl
#
use strict;
use warnings;
use LWP::UserAgent ();

#
# main
#
my @repoURLs;
my $userName 		= "";						# update this
my $githubUserName 	= (@ARGV) ? $ARGV[0] : $userName;		# override username with argument 
my $userAgent 		= "Mozilla/5.0 (X11; Linux i686; rv:10.0) Gecko/20100101 Firefox/10.0";

&check_githubName($githubUserName);
&get_public_repo_names($githubUserName);
foreach my $repoURL ( @repoURLs ) {
	&get_repo_content($repoURL);
}
#
#
#

sub check_githubName {
	my $name = shift;
	if ( $name eq "" ) {
		print "Error: need a GitHub username !\n";
		print "Either specify as argument or set the \$userName variable\n";
		exit;
	}
}

sub get_repo_content {
	my $url = shift; 
	(my $repoName) = $url =~ m|.*/(.*)|;
	
	print "[$url]\n";

	if ( -d $repoName ) {
		# repo already exist, just to pull
		`cd $repoName && git pull `;
	} else {
		# repo needs to be cloned the first time
		print `git clone $url`;
	}
}

sub get_public_repo_names {
	my $userName 	= shift;
	my $urlPre 	= 'https://github.com';
	my $urlPost	= '?tab=repositories';
	my $responseContent;

	# 
	my $url		= $urlPre . "/" . $userName . $urlPost;
	my $ua 		= LWP::UserAgent->new;
	$ua->agent("$userAgent");
	my $response 	= $ua->get($url);

 	if ($response->is_success) {
     		$responseContent = $response->decoded_content;
 	}
 	else {
     		die $response->status_line;
 	}

	while( $responseContent =~ /^(.*)/mg ) {
		my $line = $1;
		if ( $line =~ m|href=\"(.*)\".*itemprop.*codeRepository| ) {
			my $relUrl = $1;
			print "[$1]\n";
			push @repoURLs,"$urlPre$1";
		}
	}
}
