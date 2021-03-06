

use Bio::Grammar::Fasta;
use Bio::Grammar::Actions::Fasta;
role Bio::Role::FastaIO[$file]{

has @!results;
has Int $!width=80;
has $!fh;

method next_seq() {
  return shift(@!results);
}

#method will not be private and/or put in new buildmethod
method initial_read() {    
	
	#perhaps a different role.... this should be in a ROOT::IO module and not here
	if $file.WHAT ~~ IO {
 		@!results = @(Bio::Grammar::Fasta.parse($file.slurp(), :actions(Bio::Grammar::Actions::Fasta)).ast);	
	}
	else {
		#assuming this is a path to a file
		@!results = @(Bio::Grammar::Fasta.parsefile($file, :actions(Bio::Grammar::Actions::Fasta)).ast);	
	}

}

method initial_write() {    
 	#need error checking to ensure that we did indeed open a new file

	if $file.WHAT ~~ IO {
 		$!fh = $file;
	}
	else {
		$!fh = open($file,:w);
	}
}

method write_seq(*@seq){
 
 for @seq -> $seq {
   #need to ensure we have Bio::PrimarySeqI
   
   #most raw way to print out fasta files with no options whatsoever
   my $header = ">$seq.display_id() $seq.description()";

   my $sequence = $seq.seq().comb( /. ** {1..$!width}/).join("\n");
   
   $!fh.say($header ~ "\n" ~ $sequence);   
   
 }
 
}

}
