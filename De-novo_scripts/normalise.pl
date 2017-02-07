#! /usr/bin/perl -w -s
use List::Util qw<first>;

### INPUT must be single line fasta

my $K_LENGTH=25;

my %seq=();
my %kmers=();

my $fasta="";
my $seq_tot=0;
#my $counter=0;
while (<>) {
	if ($_=~/\>/) {
		$seq{$_}={};
		$seq_tot=substr((split /;/,$_)[1],5);
	} else {
		chomp;
		$fasta=$_;
		while (length($fasta)>=$K_LENGTH) {
			$kmer=substr($fasta,-25);
			if ( exists $kmers{$kmer}) {
				$kmers{$kmer}+=$seq_tot;
			} else {
				$kmers{$kmer}=$seq_tot;
			}
				

			if (exists $seq{$_}{kmer}) {
				$seq{$_}{kmer}+=$seq_tot;
			} else {
				$seq{$_}{kmer}=$seq_tot;
			}
			chop($fasta);
		}	
		$fasta="";
	}
}

#if ($fasta ne "") {
#	if (exists $seq{$fasta}) {
#		$seq{$fasta}++;
#	} else {
#		$seq{$fasta}=1;
#	}
#}




foreach my $key (sort {$kmers{$b} <=> $kmers{$a}} keys %kmers) {
	if($kmers{$key}>0) {
#		print"$key;size=$kmers{$key};\n";
	}
	foreach my $key2 (keys %seq) {
		print"$key2;$seq{$key2}{$key}";

	}
}

