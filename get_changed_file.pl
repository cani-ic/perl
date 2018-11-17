#!/usr/bin/perl -w
use File::Basename;

my $dir1=$ARGV[0];
my $dir2=$ARGV[1];
my $blank='';

system("find ./$dir1 -type f | sort -n | xargs openssl md5 > a.txt"); 
system("find ./$dir2 -type f | sort -n | xargs openssl md5 > b.txt"); 

open my $FH_DIR1,'<',"a.txt" or die;
open my $FH_DIR2,'<',"b.txt" or die;
open my $FH_OUT,'>',"output.txt" or die;
while(<$FH_DIR1>)
{
	chomp;
	my $dir1_filename_with_path = $blank;
	my $dir1_filename_no_path = $blank;
	my $dir1_hash = $blank;
	my $dir2_filename_with_path = $blank;
	my $dir2_filename_no_path = $blank;
	my $dir2_hash = $blank;
	if(/(\(.*)\)=\s(\w+)/)
	{
		$dir1_filename_with_path = $1;
		$dir1_filename_no_path = basename($1);
		#print "dir1_filename: ",$dir1_filename_with_path,"\n";
		$dir1_hash = $2;
		#print $dir1_hash,"\n";
	}
	my $dir2_line = <$FH_DIR2>;
	chomp $dir2_line;
	if($dir2_line =~ /\((.*)\)=\s(\w+)/)
	{
		$dir2_filename_with_path = $1;
		$dir2_filename_no_path = basename($1);
		#print "dir2_filename: ",$dir2_filename_with_path,"\n";
		$dir2_hash = $2;
		#print $dir2_hash,"\n";
	}
	if($dir1_filename_no_path eq $dir2_filename_no_path)
	{
		#print "filename match, continue...\n"	;
		if($dir1_hash eq $dir2_hash)
		{
			print "$dir1_filename_with_path compare to $dir2_filename_with_path: NO CHANGE,continue...\n";
		}
		else
		{
			print($FH_OUT "$dir1_filename_no_path\n");	
		}
	}
	else
	{
		print "Filename Mismatch, exit...\n"	;
		exit 7;
	}
}
close($FH_DIR1);
close($FH_DIR2);
close($FH_OUT);
system("rm -rf a.txt"); 
system("rm -rf b.txt"); 
