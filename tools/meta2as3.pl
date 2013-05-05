use strict;


use FindBin qw/$Bin/;

use lib "$Bin/perllib";

use Data::Dumper;
use JSON;

my $input_dir = "sfd/";
my $output_dir = "";
my $pack_name = "sfdvo";
my $sfd_name = "MySFD";



my  $json = JSON->new->allow_nonref;


my $PACK_DIR = $output_dir  . $pack_name . '/';
system("mkdir " . $PACK_DIR) unless -e $PACK_DIR ;


my $TABLE_TMPL = file_get_content($Bin . '/tmpl/as3.table.tmpl');
my $RECORD_TMPL = file_get_content($Bin . '/tmpl/as3.record.tmpl');
my $TABLE_ONE_TMPL = file_get_content($Bin . '/tmpl/as3.table.one.tmpl');
my $TABLE_LIST_TMPL = file_get_content($Bin . '/tmpl/as3.table.list.tmpl');
my $SFD_TMPL = file_get_content($Bin . '/tmpl/as3.sfd.tmpl');
my $SFD_ADD_TMPL = file_get_content($Bin . '/tmpl/as3.sfd.add.tmpl');
my $SFD_GET_TMPL = file_get_content($Bin . '/tmpl/as3.sfd.get.tmpl');

my @files = glob "${input_dir}*.meta";

my $sfd_loop_add_set = "";
my $sfd_loop_set = "";

for my $file (@files ) {
    my $meta = $json->decode(file_get_content($file));

    my $table_name = convert_B_name($meta->{name});
    my $rnames = $meta->{rnames};
    my $types = $meta->{types};

    #make record class
    my $record_tmpl = $RECORD_TMPL;
    my $loop_set = "";
    my $cnt = scalar @$rnames;
    for my $i(0..$cnt-1){
        my $t = $types->[$i] ;
        if ($t eq 'string') {
            $t = 'String';
        }
        $loop_set .= "\t\t\tpublic var " . $rnames->[$i] . ':' . $t . ";\n";
    }
    $record_tmpl =~ s{%LOOP_SET%}{$loop_set}gs;
    $record_tmpl =~ s{%RECORD_CLASS_NAME%}{${table_name}Record}gs;
    $record_tmpl =~ s{%PACK_NAME%}{$pack_name}gs;
    file_put_content($PACK_DIR . "${table_name}Record.as", $record_tmpl);


    #make table class
    my $table_tmpl = $TABLE_TMPL;
    my $indexes = $meta->{indexes};
    $cnt = scalar @$indexes;
    $loop_set = "";
    for my $i(0..$cnt-1){
        my $indexInfo = $indexes->[$i] ;
        my $indexArr = $indexInfo->{origin};
        my $typeArr = $indexInfo->{type};
        my $one_tmpl = $TABLE_ONE_TMPL;
        my $list_tmpl = $TABLE_LIST_TMPL;
        my $index_name = "";
        my $cnt = scalar @$indexArr ;
        my $ra_index_loop = [];
        my $ra_index_value_loop = [];
        for my $i (0..$cnt-1 ) {
            $index_name .= convert_B_name($indexArr->[$i]);
            my $bname = convert_name($indexArr->[$i]);
            push @$ra_index_value_loop, $bname;

            my $type = $typeArr->[$i];
            if ($type eq 'string') {
                $type = "String";
            }
            push @$ra_index_loop, $bname . ':' . $type;
        }

        my $index_loop = join ",", @$ra_index_loop;
        my $index_value_loop = join ",", @$ra_index_value_loop;

        $one_tmpl =~ s{%RECORD_CLASS_NAME%}{${table_name}Record}gs;
        $one_tmpl =~ s{%INDEX_NAME%}{$index_name}gs;
        $one_tmpl =~ s{%INDEX%}{$i}gs;
        $one_tmpl =~ s{%INDEX_LOOP%}{$index_loop}gs;
        $one_tmpl =~ s{%INDEX_VALUE_LOOP%}{$index_value_loop}gs;

        $list_tmpl =~ s{%RECORD_CLASS_NAME%}{${table_name}Record}gs;
        $list_tmpl =~ s{%INDEX_NAME%}{$index_name}gs;
        $list_tmpl =~ s{%INDEX%}{$i}gs;
        $list_tmpl =~ s{%INDEX_LOOP%}{$index_loop}gs;
        $list_tmpl =~ s{%INDEX_VALUE_LOOP%}{$index_value_loop}gs;

        $loop_set .= $one_tmpl . "\n\n" . $list_tmpl . "\n\n";
    }
    $table_tmpl =~ s{%LOOP_SET%}{$loop_set}gs;
    $table_tmpl =~ s{%DICT_CLASS_NAME%}{${table_name}}gs;
    $table_tmpl =~ s{%PACK_NAME%}{$pack_name}gs;
    file_put_content($PACK_DIR . "${table_name}.as", $table_tmpl);

    my $sfd_add_tmpl = $SFD_ADD_TMPL;
    my $sfd_get_tmpl = $SFD_GET_TMPL;

    $sfd_add_tmpl =~ s{%TABLE_CLASS%}{$table_name}gs;
    $sfd_add_tmpl =~ s{%TABLE%}{$meta->{name}}gs;
    $sfd_add_tmpl =~ s{%RECORD_CLASS%}{${table_name}Record}gs;

    $sfd_get_tmpl =~ s{%TABLE_CLASS%}{$table_name}gs;
    $sfd_get_tmpl =~ s{%TABLE%}{$meta->{name}}gs;
    
    $sfd_loop_add_set .= $sfd_add_tmpl . "\n";
    $sfd_loop_set .= $sfd_get_tmpl . "\n";
}



my $sfd_tmpl = $SFD_TMPL;




$sfd_tmpl =~ s{%LOOP_ADD_SET%}{$sfd_loop_add_set}gs;
$sfd_tmpl =~ s{%LOOP_SET%}{$sfd_loop_set}gs;
$sfd_tmpl =~ s{%PACK_NAME%}{$pack_name}gs;
$sfd_tmpl =~ s{%SFD_NAME%}{${sfd_name}}gs;

file_put_content($PACK_DIR . "${sfd_name}.as", $sfd_tmpl);


sub file_get_content {
    my $file = shift;
    open(F, '<', $file);
    my $content = join "", <F>;
    close F;
    return $content;
}

sub file_put_content {
    my $file = shift;
    my $c = shift;
    open(F, '>', $file);
    binmode F;
    print F $c;
    close F;
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
#aaaa_bbbb_ccc -> //AaaaBbbbCccc
sub convert_B_name {
    my $name = shift;
    my @segs = split "_", $name;
    for my $r(0..(scalar @segs-1)){
        $segs[$r] = ucfirst($segs[$r])
    }
    return join "", @segs;
}

#make sfd class


