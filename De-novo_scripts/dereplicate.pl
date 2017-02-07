#! /usr/bin/perl -w -s

my %seq=();

my $fasta="";
my $lastcount=0;
while (<>) {
	if ($_=~/\>/) {
		if ($fasta ne "") {
			if (exists $seq{$fasta}) {
				$seq{$fasta}++;
			} else {
				$seq{$fasta}=1;
			}
		}
		#$lastcount=$count;
		$fasta="";		
	} else{
		chomp;
		$fasta.=$_;
	}
}

if ($fasta ne "") {
	if (exists $seq{$fasta}) {
		$seq{$fasta}++;
	} else {
		$seq{$fasta}=1;
	}
}


my $counter=1;
foreach my $key (sort {$seq{$b} <=> $seq{$a}} keys %seq) {
	if($seq{$key}>0) {
		print">uniq.$counter;size=$seq{$key};\n$key\n";
		$counter++;
	}
}