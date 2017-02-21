#! /usr/bin/perl -w -s

#############################################################
#
# Removes identical sequences
# no sorting
#
#############################################################

my %seqs=();

my $seq="";
$seqs{""}=0;
my $counter=1;
my $output;


while (<>) {
	if ($_=~/\>/) {
		if (!exists $seqs{$seq}) {
			$output.=">Contig$counter\n$seq\n"; 
			$seqs{$seq}=1;
			$counter++;
		} 
		$seq="";		
	} else{
		chomp;
		$seq.=$_;
	}
}

$output.=">Contig$counter\n$seq\n" if !exists $seqs{$seq};

syswrite STDOUT, $output;
