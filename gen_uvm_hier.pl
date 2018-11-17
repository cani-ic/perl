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

my $exp_port        =   'exp_port';
my $exp_queue       =   'exp_queue';
my $act_port        =   'act_port';
#********************************************************************************#
    system("rm -f ./$dir/");
    system("mkdir ./$dir/");
    open my $FH_SRC,'<',$filename or die "can't open srcfile !!";
    &get_dut_clock_and_reset($FH_SRC);
#********************************************************************************#
    push (@uvm_filelist,$c_in_seqitem);
    push (@uvm_filelist,$c_out_seqitem);
    open my $FH_IN_SEQITEM,'>',"$dir/$c_in_seqitem.sv" or die;
    open my $FH_OUT_SEQITEM,'>',"$dir/$c_out_seqitem.sv" or die;
    &gen_uvm_sequence_item($FH_SRC,$FH_IN_SEQITEM,'input',$c_in_seqitem,$bc_seqitem);
    &gen_uvm_sequence_item($FH_SRC,$FH_OUT_SEQITEM,'output',$c_out_seqitem,$bc_seqitem);
    close($FH_IN_SEQITEM);
    close($FH_OUT_SEQITEM);

#*********************************generagte sequencer*************************************#
    push(@uvm_filelist,$c_sqr);
    open my $FH_MON,'>',"$dir/$c_sqr.sv";
    &gen_uvm_sequencer($FH_MON,$c_sqr,$bc_sqr);
    close($FH_MON)

#*********************************generagte driver*************************************#
    push(@uvm_filelist,$c_drv);
    open my $FH_DRV,'>',"$dir/$c_drv.sv";
    &gen_uvm_driver($FH_SRC,$FH_DRV,$c_drv,$bc_drv,$c_in_seqitem,$c_drv_dut_if,$i_drv_dut_if);
    close($FH_DRV)
    
#*********************************generagte monitor*************************************#
    push(@uvm_filelist,$c_mon);
    open my $FH_MON,'>',"$dir/$c_mon.sv";
    &gen_uvm_monitor($FH_SRC,$FH_MON);
    close($FH_MON)

#*********************************generagte agent*************************************#
    push(@uvm_filelist,$c_agt);
    open my $FH_AGT,'>',"$dir/$c_agt.sv";
    &gen_uvm_agent($FH_AGT);
    close($FH_AGT)

#*********************************generagte reference model*************************************#
    push(@uvm_filelist,$c_mdl);
    open my $FH_MDL,'>',"$dir/$c_mdl.sv";
    &gen_uvm_model($FH_MDL);
    close($FH_MDL)
#*********************************generagte scoreboard*************************************#
    push(@uvm_filelist,$c_scb);
    open my $FH_SCB,'>',"$dir/$c_scb.sv";
    &gen_uvm_scoreboard($FH_SCB);
    close($FH_SCB);
    
#*********************************generagte env*************************************#
    push(@uvm_filelist,$c_env);
    my $c_env_base ="uvm_env";
    open my $FH_ENV,'>',"$dir/$c_env.sv";
    &gen_uvm_env($FH_ENV);
    close($FH_ENV);

#*********************************generagte base_test*************************************#
    push(@uvm_filelist,$c_base_test);
    open my $FH_BASE_TEST,'>',"$dir/$c_base_test.sv" or die;
    &gen_uvm_env($FH_BASE_TEST);
    close($FH_BASE_TEST);

#*********************************generagte demo_test*************************************#
    push(@uvm_filelist,$c_demo_test);
    open my $FH_DEMO_TEST,'>',"$dir/$c_demo_test.sv" or die;
    &gen_uvm_demo_test($FH_DEMO_TEST,$c_demo_seq,$bc_demo_seq,$c_in_seqitem,$i_in_seqitem,$c_demo_test,$bc_demo_test,$i_env,$i_agt1,$i_sqr);
    close($FH_DEMO_TEST);

#*********************************generagte tb_top*************************************#
    unshift(@uvm_filelist,$c_dut_mon_if);   #含有接口的文件放到tb.sv的最上面，因为drv.sv和top.sv会调用接口
    unshift(@uvm_filelist,$c_drv_dut_if);   #含有接口的文件放到tb.sv的最上面，因为drv.sv和top.sv会调用接口
    seek($FH_SRC,0,0);  #重新将文件指针放在文件开头
    while(<$FH_SRC>)    #从源文件中获取DUT的名称，在tb中例化时，默认实例名为小写，即DUT dut(
    {
        chomp;
        #print "test\n"};
        if(/^\s*module\s+(\w+)\s*/)
        {
            $m_dut =$1; 
            $i_dut =lc($m_dut); 
            last;
        }
    }
    open my $FH_TB,'>',"$dir/$m_module.sv";     #以读写的方式打开，方便处理最后一行特殊字符
    open my $FH_DRV_DUT_IF,'>',"$dir/$c_drv_dut_if.sv";  
    open my $FH_DUT_MON_IF,'>',"$dir/$c_dut_mon_if.sv";  
    &gen_tb_top($FH_SRC,$FH_TB);
    &gen_drv_dut_if($FH_SRC,$FH_DRV_DUT_IF);
    &gen_dut_mon_if($FH_SRC,$FH_DUT_MON_IF);
    close($FH_TB);
    close($FH_DRV_DUT_IF);
    close($FH_DUT_MON_IF);

#********************************************************************************#
    open my $FH_CLR,'>',"./clean";  
    print($FH_CLR "rm -rf ./INCA_libs/\n"); 
