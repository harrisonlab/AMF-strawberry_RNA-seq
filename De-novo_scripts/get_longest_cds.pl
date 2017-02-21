#! /usr/bin/perl -w -s
use List::MoreUtils 'first_index';
use List::MoreUtils qw(indexes);

###########################################################
#
# Outputs longst ORF found in input sequence
# Optionally sorts by length (not implemented)
#
###########################################################

my @seqs;
my $sortme=0;

my $header="";
my $seq="";
my $h1="";
my @idx;
my $cds;
my $output;

while (<>) {
	if ($_=~/\>/) {
		$h1=$_;
		$cds = get_cds($seq);
		push @seqs, ([$header, $cds, length($cds)]);
		$seq="";		
	} else{
		chomp;
		$_=~s/\s+$//;
		$header=$h1;
		$seq.=$_;
	}
}

$cds = get_cds($seq,1);

push @seqs,([$header,$cds,length($cds)]);
shift @seqs;

my @sorted= @seqs;

@sorted = sort { $b->[2] <=> $a->[2] } @seqs if $sortme;

foreach(@sorted) {
	$output.= sprintf "%s%s\n",@{$_};
}

syswrite STDOUT, $output;

sub get_cds {
	my ($s,$test) =  @_;
	my $rcs = reverse_compliment($s);
	my @ss;
	$ss[0] = get_ss($s);
	$ss[1] = get_ss($rcs);
	$seq =~ s/^.//s;
	$rcs =~ s/^.//s;
	$ss[2] = get_ss($s);
	$ss[3] = get_ss($rcs);
	$seq =~ s/^.//s;
	$rcs =~ s/^.//s;
	$ss[4] = get_ss($s);
	$ss[5] =get_ss($rcs);
	my $longest = longest_strarray($ss[0]);	
	$longest=~s/N//g;
	return($longest);
}

sub reverse_compliment {
	my ($s)=@_;
	$s=~tr/atcgATCG/tagcTAGC/;
	my $s2=reverse $s;
	return($s2);
}

sub get_ss {
	my ($s)=@_;
	my @ind1 = indexes { /TAG|TAA|TGA/ } ( $s =~ m/.../g ); # this finds all stop codons - which is also a map of potential ORFs
	return($s) if !@ind1;
	my @ind2 = @ind1;
	push @ind2,length($s)/3;
	shift @ind2;
	my @ind3;
	for (my $i=0;$i<scalar @ind1;$i++){
    		$ind3[$i]= $ind2[$i] - $ind1[$i] -1; 
	}
	my $index = max_numarray_idx(@ind3);
	my $l = substr($s,(($ind1[$index])*3),(($ind2[$index]-$ind1[$index]+1)*3));
	$l="N".$l if $l!~/^T(AG|AA|GA)/; # breaks ties in favour of incomplete ORF
	$l.="N" if $l!~/T(AG|AA|GA)$/;
	return($l);
}


sub max_numarray_idx {
	my $idxMax = 0;
	my (@data) = @_;
	$data[$idxMax] > $data[$_] or $idxMax = $_ for 1 .. $#data;
	return($idxMax);
}

sub longest_strarray {
	my (@array) = @_;
	my $longest = $array[0];
	my $len = length $longest;
	for my $str (@array) {
		if ( length($str) > $len ) {
			$longest = $str;
			$len = length($str);
		}
	}
	return $longest;
}