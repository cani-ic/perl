#!/bin/perl

#********************************************************************************#
my @uvm_filelist;
my $argnum = $#ARGV + 1;
my $filename;
my $blank;
my $reset='Reset_N';
my $clk='GClk';
my $m_dut;
my $i_dut;
#********************************************************************************#
if(-e "./dut")
{;}
else
{   print "ERROR: create a directory named \"dut\",and put needed files into it ,then try again!!!\n "}
    exit 7;
}

if($ARGV[0] eq $blank ) #不加参数时报错，直接退出
{
    print "Usage: $0 -m|--module modulename -f filename \n";
    exit 7;
}
for(my $i=1;$i<=$argnum;$i++)   #遍历，解析命令行参数
{
    last if $ARGV[0] eq $blank;

    if($ARGV[0] eq '-h' || $ARGV[0] eq '--help')    #ARGV[0]表示第一个命令行参数
    {
        print "Usage: $0 -m|--module modulename -f filename \n";
        exit 0;
    }
    elsif($ARGV[0] eq '-m' || $ARGV[0] eq '--module') 
    {
        $modulename=lc($ARGV[1]);
        shift;
        shift;
    }
    elsif($ARGV[0] eq '-f') 
    {
        $filename=$ARGV[1];
        shift;
        shift;
    }
    else
    {
        print "Usage: $0 -m|--module modulename -f filename \n";
        exit 7;
    }
}

#*******************************************UVM 平台变量*****************************#
#声明为全局变量
my $c_in_seqitem    =   "input_trans_".$modulename;
my $c_out_seqitem   =   "output_trans_".$modulename;
my $c_sqr           =   "sqr_".$modulename;
my $c_drv           =   "drv_".$modulename;
my $c_mon           =   "mon_".$modulename;
my $c_agt           =   "agt".$modulename;
my $c_mdl           =   "mdl_".$modulename;
my $c_scb           =   "scb_".$modulename;
my $c_env           =   "env_".$modulename;
my $c_base_test     =   "base_test_".$modulename;
my $c_demo_seq      =   "demo_seq_".$modulename;
my $c_demo_test     =   "demo_test_".$modulename;
my $c_drv_dut_if    =   "drv_dut_if_".$modulename;
my $c_dut_mon_if    =   "dut_mon_if_".$modulename;

my $m_module        =   "tb_".$modulename;
my $dir             =   "env_".$modulename;

my $i_in_seqitem    =   "my_item";
my $i_sqr           =   "my_sqr";
my $i_drv           =   "my_drv";
my $i_mon           =   "my_mon";
my $i_agt1          =   "my_agt_i";
my $i_agt2          =   "my_agt_o";
my $i_mdl           =   "my_mdl";
my $i_scb           =   "my_scb";
my $i_env           =   "my_env";
my $i_drv_dut_if    =   "i_drv_dut_if";
my $i_dut_mon_if    =   "o_dut_mon_if";
my $i_drv_ap        =   "drv_ap"
my $i_mon_ap        =   "mon_ap"
my $agt_mdl_fifo    =   "agt_mdl_fifo";
my $agt_scb_fifo    =   "agt_scb_fifo";
my $mdl_scb_fifo    =   "mdl_scb_fifo";

my $bc_seqitem      =   "uvm_sequence_item";
my $bc_sqr          =   "uvm_sequencer";
my $bc_drv          =   "uvm_driver";
my $bc_mon          =   "uvm_monitor";
my $bc_agt          =   "uvm_agent";
my $bc_mdl          =   "uvm_component";
my $bc_scb          =   "uvm_scoreboard";
my $bc_base_test    =   "uvm_test";
my $bc_demo_seq     =   "uvm_sequence";
my $bc_demo_test    =   $c_base_test;

