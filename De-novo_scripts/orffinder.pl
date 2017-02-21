#!/usr/bin/perl
use warnings;
use strict;
use List::MoreUtils 'first_index';
use List::MoreUtils qw(indexes);
 

my $header="";
my $seq="";
my $h1="";
my @idx;

while(<>) {
	chomp;
	if($_=~/\>/) {
		$h1=$_;
		if (length($seq)>0){
			main();
		}
		$seq="";
	} else {
		$header=$h1;
		$seq.=$_;
	}
}

if (length($seq)>0){
	main();
}



sub main {
	my $rcseq = reverse_compliment($seq);
	$idx[0] = get_idx($seq);
	$idx[1] = get_idx($rcseq);
	$seq =~ s/^.//s;
	$rcseq =~ s/^.//s;
	$idx[2] = get_idx($seq);
	$idx[3] = get_idx($rcseq);
	$seq =~ s/^.//s;
	$rcseq =~ s/^.//s;
	$idx[4] = get_idx($seq);
	$idx[5] =get_idx($rcseq);

	my $itop = max_numarray_idx(@idx);
	$header=~ s/^.//s;
	print "$header\t";
	print length($seq);
	print "\t";
	print $idx[$itop]*3;
	print "\t$itop\n";
}

sub reverse_compliment {
	my ($s)=@_;
	$s=~tr/atcgATCG/tagcTAGC/;
	reverse $s;
}

sub get_idx {
	my ($s)=@_;
	my @ind1 = indexes { /TAG|TAA|TGA/ } ( $s =~ m/.../g ); # this finds all stop codons - which is also a map of potential ORFs
	return(-1) if !$ind1[0];
	push @ind1,length($s)/3+1;	
	my @ind2 = @ind1;
	pop @ind1;
	shift @ind2;
	my @ind3;
	for (my $i=0;$i<scalar @ind1;$i++){
    		$ind3[$i]= $ind2[$i] - $ind1[$i] -1; 
	}
	unshift @ind3,(shift @ind1);
	$ind3[max_numarray_idx(@ind3)];
}


sub max_numarray_idx {
	my $idxMax = 0;
	my @data = @_;
	my $m1 = first_index {/-1/} @data;
	return($m1) if $m1>-1;    
	$data[$idxMax] > $data[$_] or $idxMax = $_ for 1 .. $#data;
	return($idxMax);
}
