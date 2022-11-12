#!/usr/bin/perl
#
use strict;
use warnings;
use LWP::UserAgent ();

#
# main
#
my @repoURLs;
my $userName 		= 'ademol';					# update this
my $backupPath		= '.';						# update this
my $githubUserName 	= ($ARGV[0]) ? $ARGV[0] : $userName;		# override username with argument 
my $localBackupPath 	= ($ARGV[1]) ? $ARGV[1] : $backupPath;		# override path with argument 
my $userAgent 		= "Mozilla/5.0 (X11; Linux i686; rv:10.0) Gecko/20100101 Firefox/10.0";


&validate_githubName($githubUserName);
&get_public_repo_names($githubUserName);
foreach my $repoURL ( @repoURLs ) { 
	&get_repo_content($repoURL); 
}
#
#
#

sub validate_githubName {
	my $name = shift;
	if ($name eq "") {
		print "Error: need a GitHub username !\n";
		print "Either specify as argument or set the \$userName variable\n";
		exit;
	}
}

sub get_repo_content {
	my $url = shift; 
	(my $repoName) = $url =~ m|.*/(.*)|;
		
	print "[$url][$localBackupPath]\n";

	if ( -d "$localBackupPath/$repoName" ) {
		# repo already exist, just to pull
		print "pulling [$repoName]\n";
		`cd $localBackupPath && cd $repoName && git pull `;
	} else {
		print "cloning [$repoName]\n";
		# repo needs to be cloned the first time
		print `cd $localBackupPath && git clone $url`;
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
