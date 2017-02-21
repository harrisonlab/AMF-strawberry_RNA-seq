#! /usr/bin/perl -w -s
use List::Util qw<first>;
use MCE::Grep;
MCE::Grep::init({max_workers => 16});
#	MCE::Grep::init({max_count => 1});
#use Benchmark qw(:all) ;

#########################################################################
#
# Removes sequences which are an identical substring of longer sequence
# Input sequences must be sorted by length
#
########################################################################

my %seqs=();

my $header="";
my $h1="";
my $seq="";
my $output;
my $match;

my $bigstr="\n";


while (<>) {
	chomp;
	if ($_=~/\>/) {
		#$_=~s/^.//s;
		$h1=$_;
		my $m = keys %seqs;
		my $keymatch = grep{$seq}(keys %seqs);
		print "$m...$seq...$keymatch\n";
		#my $keymatch = (first { m/$seq/ } keys %seqs ) || ''; 
		if ($keymatch) {
			#$match.="MATCH: $seqs{$keymatch} FRAG: $header\n";
		} else {
			$seqs{$seq}=$header;
		}
		$seq="";		
	} else{
		$header=$h1;
		$seq.=$_;
	}
}

if ($seq ne "") {
	my $keymatch = (first { m/$seq/ } keys %seqs ) || ''; 
	if ($keymatch) {
		$match.="MATCH: $seqs{$keymatch}  FRAG: $header\n";
	} else {
		$seqs{$seq}=$header;
	}
}


foreach my $key (keys %seqs) {
	$output.="$seqs{$key}\n$key\n";
}

syswrite STDOUT,$output,length($output),2;
syswrite STDERR,$match;



