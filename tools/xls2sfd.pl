use strict;


use FindBin qw/$Bin/;

use lib "$Bin/perllib";

use Spreadsheet::XLSX;
use Data::Dumper;
use JSON;

my $input_dir = "";
my $output_dir = "";

my  $json = JSON->new->allow_nonref;
my $SFD_DIR = $output_dir  . "sfd";
system("mkdir " . $SFD_DIR)  unless -e $SFD_DIR;
my @files = glob "${input_dir}*.xlsx";
for my $file (@files ) {
	if ($file =~ m{\$}){
		#tmp file
		next;
	}
	parse_file($file);
}


#aaaa_bbbb_ccc -> //aaaaBbbbCccc
sub convert_name {
	my $name = shift;
	my @segs = split "_", $name;
	for my $r(1..(scalar @segs-1)){
		$segs[$r] = ucfirst($segs[$r])
	}
	return join "", @segs;
}
sub parse_file {
	my $file = shift;
	my $excel = Spreadsheet::XLSX -> new ($file);
	foreach my $sheet (@{$excel -> {Worksheet}}) {
 		
        #printf("Sheet: %s\n", $sheet->{Name});
        $sheet -> {MaxRow} ||= $sheet -> {MinRow};
		$sheet -> {MaxCol} ||= $sheet -> {MinCol};

        #first cell (0,0) is the table info
        my $table_meta_info = $json->decode($sheet -> {Cells}[0][0]-> {Val});
        my $table_info = {
        	name => $table_meta_info->{name} || $sheet->{Name},
        };

        my $body_start = $table_meta_info->{body_start} || 5,
        my $ra_indexes = $table_meta_info->{indexes};

        #second line is the column type, int,  long string(4 bytes length, not implemented now)
        my @types = ();
        foreach my $col(0..$sheet -> {MaxCol} ) {
        	my $cell = $sheet -> {Cells} [1] [$col];
        	if ($cell-> {Val} ne 'int' and $cell-> {Val} ne 'string') {
        		die "wrong cell type at " . $file . "," . $sheet->{Name} . "," . "col " . $col;
        	}
        	push @types, $cell-> {Val};
        }


        #third line is the column name
        my @names = ();
     	my @rnames = ();       	
        my $rh_name = {};
        foreach my $col(0..$sheet -> {MaxCol} ) {
        	my $cell = $sheet -> {Cells} [2] [$col];
        	$rh_name->{$cell-> {Val}} = $col;
        	my $name = $cell-> {Val};
        	$name =~ s{\s}{}gis;
       		push @names, $name;
        	push @rnames, convert_name($name);
        }


     


        my @records = ();
        foreach my $row( $body_start..$sheet -> {MaxRow} ) {
        	my $record = [];
        	foreach my $col(0..$sheet -> {MaxCol} ) {
	        	my $cell = $sheet -> {Cells} [$row] [$col];
	        	push @$record, $cell->{Val};
	        }
	        push @records, $record;
        }

        #convert indexes name -> column index
        my @indexes = ();
        for my $ra_index(@$ra_indexes){
        	my $ra_index_column = [];
        	my $ra_index_type = [];
        	for my $r (@$ra_index) {
        		push @$ra_index_column, $rh_name->{$r};
        		push @$ra_index_type, $types[$rh_name->{$r}];

        	}
        	push @indexes, {origin => $ra_index, column => $ra_index_column, type=>$ra_index_type, _data=> {}};	
        }
     

		# print Dumper($table_info);
		# print Dumper(\@types);
		# print Dumper(\@names);
		# print Dumper(\@records);
	

        #save records to $name.body
        my @positions = ();
        my $i;
        my $records_count = scalar @records;



        open(F, '>', $SFD_DIR . "/"  . $table_info->{name} . '.body');
        binmode F;
        my $offset = 0;
        for ($i=0;$i<$records_count;$i++) {
        	#save record
        	my $record = $records[$i];
        	push @positions, $offset;
        	my $c = scalar @types;
        	my $j;
        	for ($j=0;$j<$c;$j++) {
        		my $type = $types[$j];
        		#write data
        		if ($type eq 'int') {
        			#4 bytes
        			print F pack("N", int($record->[$j]));	
        			$offset += 4;
        		} elsif ($type eq 'string') {
        			my $s = $record->[$j];
        			my $l = length($s);
        			print F pack("n", $l);
        			print F $s;
        			$offset += 2 + $l;	
        		}
        	}

        	for my $index (@indexes) {
        		my $ra_index_column = $index->{column};
        		my $data = $index->{_data};
        		my $len = @$ra_index_column;

        		for my $ri(0..$len-1){
        			my $r = $ra_index_column->[$ri];
        			my $v = $record->[$r];
        			

    				if ($ri == $len -1){
    					#leaf
						if (!exists $data->{$v} ) {
	        				$data->{$v} = [];	
	    				} 
	    				push @{$data->{$v}}, $i;
    				} else{
    					if (!exists $data->{$v} ) {
	        				$data->{$v} = {};	
	    				} 
	    				$data = $data->{$v};
    				}
    				
    					
        		}
        		
        	}

        }
        close F;

        
		#print Dumper(\@indexes);

		
		#save positions to $name.pos.
		open(F, '>', $SFD_DIR . "/"  . $table_info->{name} . '.pos');
		binmode F;
		for my $p(@positions) {
			print F pack("N", $p);
		}
		close F;

        #save indexes to $name.index.
		open(F, '>', $SFD_DIR  . "/" . $table_info->{name} . '.index');
		print F $json->encode(\@indexes);
		close F;

        #save table meta data to meta\$name.meta
		$table_info->{types} = \@types;
		$table_info->{names} = \@names;
		$table_info->{rnames} = \@rnames;

	
		#copy indexs origin name and type into meta
		for my $rh_index(@indexes){
        	delete $rh_index->{_data}
        }
		$table_info->{indexes} = \@indexes;

		open(F, '>', $SFD_DIR . "/". $table_info->{name} . '.meta');
		print F $json->encode($table_info);
		close F;

 	}
}


