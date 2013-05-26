use strict;


use FindBin qw/$Bin/;

use lib "$Bin/perllib";

use Data::Dumper;
use JSON;
my $LANG = $ARGV[0] || "as3";
my $input_dir = $ARGV[1] || "sfd/";
my $output_dir = $ARGV[2] || "";
my $pack_name = "sfdvo";
my $sfd_name = "MySFD";



my  $json = JSON->new->allow_nonref;


my $PACK_DIR = $output_dir  . $pack_name . '/';
system("mkdir " . $PACK_DIR) unless -e $PACK_DIR ;



my $ext = get_ext();

my $TABLE_TMPL = file_get_content($Bin . "/tmpl/$LANG.table.tmpl");
my $RECORD_TMPL = file_get_content($Bin . "/tmpl/$LANG.record.tmpl");
my $RECORD_ONE_TMPL = file_get_content($Bin . "/tmpl/$LANG.record.one.tmpl");
my $TABLE_ONE_TMPL = file_get_content($Bin . "/tmpl/$LANG.table.one.tmpl");
my $TABLE_ARGS_TMPL = file_get_content($Bin . "/tmpl/$LANG.table.args.tmpl");
my $TABLE_LIST_TMPL = file_get_content($Bin . "/tmpl/$LANG.table.list.tmpl");
my $SFD_TMPL = file_get_content($Bin . "/tmpl/$LANG.sfd.tmpl");
my $SFD_ADD_TMPL = file_get_content($Bin . "/tmpl/$LANG.sfd.add.tmpl");
my $SFD_GET_TMPL = file_get_content($Bin . "/tmpl/$LANG.sfd.get.tmpl");

my @files = glob "${input_dir}*.meta";

my $sfd_loop_add_set = "";
my $sfd_loop_set = "";

for my $file (@files ) {
    print $file . "\n";
    my $meta = $json->decode(file_get_content($file));

    my $table_name = convert_B_name($meta->{name});
    my $rnames = $meta->{rnames};
    my $types = $meta->{types};

    #make record class
    my $record_tmpl = $RECORD_TMPL;
    my $loop_set = "";
    my $cnt = scalar @$rnames;
    for my $i(0..$cnt-1){
        my $t = type_cast($types->[$i] );
       
        my $r_one = $RECORD_ONE_TMPL;
        $r_one =~ s{%VAR%}{$rnames->[$i]}s;
        $r_one =~ s{%TYPE%}{$t}s;
        $r_one =~ s{%RECORD_CLASS_NAME%}{${table_name}Record}gs;
        $loop_set .= $r_one;
    }
    $record_tmpl =~ s{%LOOP_SET%}{$loop_set}gs;
    $record_tmpl =~ s{%RECORD_CLASS_NAME%}{${table_name}Record}gs;
    $record_tmpl =~ s{%PACK_NAME%}{$pack_name}gs;
    file_put_content($PACK_DIR . "${table_name}Record.$ext", $record_tmpl);


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

            my $type = type_cast($typeArr->[$i]);
            my $args_tmpl = $TABLE_ARGS_TMPL;
            $args_tmpl =~ s{%VALUE%}{$bname}gs;
            $args_tmpl =~ s{%TYPE%}{$type}gs;
            push @$ra_index_loop, $args_tmpl;
        }

        my $index_loop = join_args($ra_index_loop);
        my $index_value_loop = join ",", @$ra_index_value_loop;
        my $real_index = get_index($i);
        $one_tmpl =~ s{%RECORD_CLASS_NAME%}{${table_name}Record}gs;
        $one_tmpl =~ s{%INDEX_NAME%}{$index_name}gs;
        $one_tmpl =~ s{%INDEX%}{$real_index}gs;
        $one_tmpl =~ s{%INDEX_LOOP%}{$index_loop}gs;
        $one_tmpl =~ s{%INDEX_VALUE_LOOP%}{$index_value_loop}gs;

        $list_tmpl =~ s{%RECORD_CLASS_NAME%}{${table_name}Record}gs;
        $list_tmpl =~ s{%INDEX_NAME%}{$index_name}gs;
        $list_tmpl =~ s{%INDEX%}{$real_index}gs;
        $list_tmpl =~ s{%INDEX_LOOP%}{$index_loop}gs;
        $list_tmpl =~ s{%INDEX_VALUE_LOOP%}{$index_value_loop}gs;

        $loop_set .= $one_tmpl . "\n\n" . $list_tmpl . "\n\n";
    }
    $table_tmpl =~ s{%LOOP_SET%}{$loop_set}gs;
    $table_tmpl =~ s{%DICT_CLASS_NAME%}{${table_name}}gs;
    $table_tmpl =~ s{%PACK_NAME%}{$pack_name}gs;
    file_put_content($PACK_DIR . "${table_name}.$ext", $table_tmpl);

    my $sfd_add_tmpl = $SFD_ADD_TMPL;
    my $sfd_get_tmpl = $SFD_GET_TMPL;

    $sfd_add_tmpl =~ s{%TABLE_CLASS%}{$table_name}gs;
    $sfd_add_tmpl =~ s{%TABLE%}{$meta->{name}}gs;
    $sfd_add_tmpl =~ s{%PACK_NAME%}{$pack_name}gs;
    $sfd_add_tmpl =~ s{%RECORD_CLASS%}{${table_name}Record}gs;
    $sfd_add_tmpl =~ s{%SFD_NAME%}{${sfd_name}}gs;
    
    $sfd_get_tmpl =~ s{%TABLE_CLASS%}{$table_name}gs;
    $sfd_get_tmpl =~ s{%TABLE%}{$meta->{name}}gs;
    $sfd_get_tmpl =~ s{%PACK_NAME%}{$pack_name}gs;
    $sfd_get_tmpl =~ s{%SFD_NAME%}{${sfd_name}}gs;
    $sfd_loop_add_set .= $sfd_add_tmpl . "\n";
    $sfd_loop_set .= $sfd_get_tmpl . "\n";
}



my $sfd_tmpl = $SFD_TMPL;




$sfd_tmpl =~ s{%LOOP_ADD_SET%}{$sfd_loop_add_set}gs;
$sfd_tmpl =~ s{%LOOP_SET%}{$sfd_loop_set}gs;
$sfd_tmpl =~ s{%PACK_NAME%}{$pack_name}gs;
$sfd_tmpl =~ s{%SFD_NAME%}{${sfd_name}}gs;

file_put_content($PACK_DIR . "${sfd_name}.$ext", $sfd_tmpl);


sub type_cast{
    my $t = shift;
    if ($LANG eq 'as3'){
         if ($t eq 'string') {
            $t = "String";
        }
    }
    return $t;
}
sub get_index {
    my $i = shift;
    if ($LANG eq 'lua'){
        return $i+1;
    }
    return $i;
}
sub get_ext {
    if ($LANG eq 'as3'){
        return "as";
    } elsif ($LANG eq 'lua'){
        return "lua";
    }
}

sub join_args{
    my $ra = shift;
    if ($LANG eq 'as3'){
        return join(",", @$ra);
    } elsif ($LANG eq 'lua'){
        return join("\n", @$ra);
    }
}

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


