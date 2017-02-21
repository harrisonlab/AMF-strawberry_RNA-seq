#! /usr/bin/perl -w -s

my @seqs;
my $sortme=0;

my $header="";
my $seq="";
my $h1="";
my $output;

while (<>) {
	if ($_=~/\>/) {
		$h1=$_;
		push @seqs, ([$header, $seq]) if (length($seq)>=99) && ($seq=~/^T(AG|AA|GA).*T(AG|AA|GA)$/ );
		$seq="";		
	} else{
		chomp;
		$header=$h1;
		$seq.=$_;
	}
}

push @seqs, ([$header, $seq]) if (length($seq)>=99) && ($seq=~/^T(AG|AA|GA).*T(AG|AA|GA)$/ );

foreach(@seqs) {
	$output.= sprintf "%s%s\n",@{$_};
}

syswrite STDOUT, $output;
