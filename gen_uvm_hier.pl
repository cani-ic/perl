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
    print($FH_CLR "rm -rf ./$modulename.lis\n"); 
    print($FH_CLR "rm -rf ./$dir.lis\n"); 
    print($FH_CLR "rm -rf ./$modulename.shm/\n"); 
    print($FH_CLR "rm -rf ./irun.log/\n"); 
    print($FH_CLR "rm -rf ./run/\n"); 
    close($FH_CLR)
    system("chmod u+x clean");
#********************************************************************************#
    open my $FH_IRUN,'>',"./run";
    print($FH_IRUN "rm -rf ./INCA_libs/\n"); 
    print($FH_IRUN "irun -sv -f $modulename.lis -access +rwc -timescale 1ns/1ps -uvm +UVM_TESTNAME=$c_demo_test"); 
    close($FH_IRUN);
    system("chmod u+x run");
#********************************************************************************#
    open my $FH_LIST,'>',"./modulename.lis";
    print($FH_LIST "-NONWARN NONPRT\n");
    print($FH_LIST "-incdir ./$dir\n");
    print($FH_LIST "-incdir ./dut\n");
    print($FH_LIST "./dut/*.v\n");
    print($FH_LIST "./$dir/$m_module.sv\n");
    close($FH_LIST);
#********************************************************************************#
    sub gen_dut_mon_if
    {
       (my $fh_src,my $fh_dst)=@_;
       print($fh_dst "interface $c_dut_mon_if\(input $clk,input $reset\);\n");
       $string2replace($fh_src,$fh_dst,"(?:in|out)put","logic");
       print($fh_dst "endinterface\n");
    }
#********************************************************************************#
    sub gen_drv_mon_if
    {
       (my $fh_src,my $fh_dst)=@_;
       print($fh_dst "interface $c_drv_mon_if\(input $clk,input $reset\);\n");
       $string2replace($fh_src,$fh_dst,"(?:in|out)put","logic");
       print($fh_dst "endinterface\n");
    }
#********************************************************************************#
    sub gen_tb_top
    {
        my $fh_src=shift;
        my $fh_dst=shift;
        &module_declare($fh_dst);
        &clock_and_reset($fh_dst);
        &open_wave($fh_dst,$i_dut);
        &interface_declare($fh_dst,$m_module,$c_drv_dut_if,$i_drv_dut_if);
        &interface_declare($fh_dst,$m_module,$c_dut_mon_if,$i_drv_dut_if);
        &dut_instantize($fh_src,$fh_dst);
        &interface_connect_and_run_test($fh_dst);
        &print_module_end($fh_dst);
    }
#********************************************************************************#
    sub gen_uvm_demo_test
    {
        my $fh_dst=shift;
        &print_class_head($fh_dst,$c_demo_seq,$bc_demo_seq);
            &uvm_utils($fh_dst,"object",$c_demo_seq);
            &class_declare($fh_dst,$c_in_seqitem,$i_in_seqitem);
            &object_new($fh_dst,$c_demo_seq);
            &task_func_declare($fh_dst,'task','pre_body','');
            &task_func_declare($fh_dst,'task','body','');
            &task_func_declare($fh_dst,'task','post_body','');
        &print_class_end($fh_dst);
        &print_class_head($fh_dst,$c_demo_seq,$bc_demo_test);
            &uvm_utils($fh_dst,"component",$c_demo_test);
            &component_new($fh_dst,$c_demo_test);
            &task_func_declare($fh_dst,'function void','build_phase','uvm_phase phase','');
        &print_class_end($fh_dst);
        &seq_pre_body($fh_dst);
        &seq_body($fh_dst);
        &seq_post_body($fh_dst);
        &demo_test_bulid_phase($fh_dst);
    }
#********************************************************************************#
    sub gen_uvm_base_test
    {
        my $fh_dst=shift;
        &print_class_head($fh_dst,$c_base_test,$bc_base_test);
            &uvm_utils($fh_dst,"component",$c_base_test);
            &class_declare($fh_dst,$c_env,$i_env);
            &component_new($fh_dst,$c_base_test);
            &task_func_declare($fh_dst,'function void','build_phase','uvm_phase phase');
            &task_func_declare($fh_dst,'function void','start_of_simulation_phase','uvm_phase phase');
            &task_func_declare($fh_dst,'function void','report_phase','uvm_phase phase');
        &print_class_end($fh_dst);
        &base_test_bulid_phase($fh_dst);
        &test_start_of_simulation_phase($fh_dst);
        &test_report_phase($fh_dst);
#       &task_testcase_run_phase($fh_dst,$i_seq,i_env,$i_sqr);
    }
#********************************************************************************#
    sub gen_uvm_env
    {
        my $fh_dst=shift;
        &print_class_head($fh_dst,$c_env,$c_env_base)
            &uvm_utils($fh_dst,"component",$c_env);
            &class_declare($fh_dst,$c_agt,$i_agt1);
            &class_declare($fh_dst,$c_agt,$i_agt2;
            &class_declare($fh_dst,$c_mdl,$i_mdl);
            &class_declare($fh_dst,$c_scb,$i_scb);
            &port_declare($fh_dst,"uvm_tlm_analysis_fifo",$c_in_seqitem,$agt_mdl_fifo);
            &port_declare($fh_dst,"uvm_tlm_analysis_fifo",$c_out_seqitem,$agt_scb_fifo);
            &port_declare($fh_dst,"uvm_tlm_analysis_fifo",$c_out_seqitem,$mdl_scb_fifo);
            &component_new($fh_dst,$c_env);
            &task_func_declare($fh_dst,'function void','build_phase','uvm_phase phase');
            &task_func_declare($fh_dst,'function void','connect_phase','uvm_phase phase');
        &print_class_end($fh_dst);
        &env_bulid_phase($fh_dst);
        &env_connect_phase($fh_dst);
    }
#********************************************************************************#
    sub gen_uvm_scoreboard
    {
        my $fh_dst=shift;
        &print_class_head($fh_dst,$c_scb,$bc_scb)
            &uvm_utils($fh_dst,"component",$c_scb);
            &class_declare($fh_dst,$c_out_seqitem,"$exp_queue\[\$\]");
            &port_declare($fh_dst,"uvm_blocking_get_port",$c_out_seqitem,$exp_port);
            &port_declare($fh_dst,"uvm_blocking_get_port",$c_out_seqitem,$act_port);
            &component_new($fh_dst,$c_scb);
            &task_func_declare($fh_dst,'function void','build_phase','uvm_phase phase');
            &task_func_declare($fh_dst,'task','main phase','uvm_phase phase');
        &print_class_end($fh_dst);
        &scoreboard_bulid_phase($fh_dst);
        &scoreboard_main_phase($fh_dst);
    }
#********************************************************************************#
    sub gen_uvm_model
    {
        my $fh_dst=shift;
        &print_class_head($fh_dst,$c_mdl,$bc_mdl)
            &uvm_utils($fh_dst,"component",$c_mdl);
            &port_declare($fh_dst,"uvm_blocking_get_port",$c_in_seqitem,"port");
            &port_declare($fh_dst,"uvm_analysis_port",$c_out_seqitem,"ap");
            &component_new($fh_dst,$c_mdl);
            &task_func_declare($fh_dst,'function void','build_phase','uvm_phase phase');
            &task_func_declare($fh_dst,'task','main_phase','uvm_phase phase');
        &print_class_end($fh_dst);
        &model_bulid_phase($fh_dst);
        &model_main_phase($fh_dst);
    }
#********************************************************************************#
    sub gen_uvm_agent
    {
        my $fh_dst=shift;
        &print_class_head($fh_dst,$c_agt,$bc_agt)
            &uvm_utils($fh_dst,"component",$c_agt);
            &class_declare($fh_dst,$c_sqr,$i_sqr);
            &class_declare($fh_dst,$c_drv,$i_drv);
            &class_declare($fh_dst,$c_mon,$i_mon);
            &port_declare($fh_dst,"uvm_analysis_port",$c_in_seqitem,$i_drv_ap);
            &port_declare($fh_dst,"uvm_analysis_port",$c_out_seqitem,$i_mon_ap);
            &component_new($fh_dst,$c_agt);
            &task_func_declare($fh_dst,'function void','build_phase','uvm_phase phase');
            &task_func_declare($fh_dst,'function void','connect_phase','uvm_phase phase');
        &print_class_end($fh_dst);
        &agent_bulid_phase($fh_dst);
        &agent_connect_phase($fh_dst);
    }
#********************************************************************************#
    sub gen_uvm_driver
    {
        my $fh_src=shift;
        my $fh_dst=shift;
        &print_class_head($fh_dst,$c_drv,$bc_drv)
            &uvm_utils($fh_dst,"component",$c_drv);
            &class_declare($fh_dst,"virtual $c_drv_dut_if",$i_drv_dut_if);
            &port_declare($fh_dst,"uvm_analysis_port",$c_in_seqitem,"ap");
            &component_new($fh_dst,$c_drv);
            &task_func_declare($fh_dst,'function void','build_phase','uvm_phase phase');
            &task_func_declare($fh_dst,'task','main_phase','uvm_phase phase');
            &task_func_declare($fh_dst,'task','drive_one_item',"$c_in_seqitem tr");
        &print_class_end($fh_dst);
        &driver_bulid_phase($fh_dst);
        &driver_main_phase($fh_dst);
        &driver_one_item($fh_dst,$fh_src);
    }
#********************************************************************************#
    sub gen_uvm_monitor
    {
        my $fh_src=shift;
        my $fh_dst=shift;
        &print_class_head($fh_dst,$c_mon,$bc_mon)
            &uvm_utils($fh_dst,"component",$c_mon);
            &class_declare($fh_dst,"virtual $c_dut_mon_if",$i_dut_mon_if);
            &port_declare($fh_dst,"uvm_analysis_port",$c_out_seqitem,"ap");
            &component_new($fh_dst,$c_mon);
            &task_func_declare($fh_dst,'function void','build_phase','uvm_phase phase');
            &task_func_declare($fh_dst,'task','main_phase','uvm_phase phase');
            &task_func_declare($fh_dst,'task','collect_one_item',"$c_out_seqitem tr");
        &print_class_end($fh_dst);
        &monitor_bulid_phase($fh_dst);
        &monitor_main_phase($fh_dst);
        &collect_one_item($fh_dst,$fh_src);
    }
#********************************************************************************#
    sub gen_uvm_sequencer
    {
        (my $fh_dst,my $c_sqr,$bc_sqr)=@_;

        &print_class_head($fh_dst,$c_sqr,$bc_sqr)
            &uvm_utils($fh_dst,"component",$c_sqr);
            &component_new($fh_dst,$c_sqr);
        &print_class_end($fh_dst);
    }
#********************************************************************************#
    sub gen_uvm_sequence_item
    {
        (my $fh_src,my $fh_dst,my $in_out,my $c_in_seqitem,my $bc_seqitem)=@_;

        &print_class_head($fh_dst,$c_in_seqitem,$bc_seqitem)
            &object_new($fh_dst,$c_in_seqitem);
            if($in_out eq 'input')
            {
                &string2replace($fh_src,$fh_dst,$in_out,"rand bit");
                &uvm_field_declare($fh_src,$fh_dst,$in_out,$c_in_seqitem);
                &set_base_cons($fh_src,$fh_dst)
            }
            else
            {
                &string2replace($fh_src,$fh_dst,$in_out,"bit");
                &uvm_field_declare($fh_src,$fh_dst,$in_out,$c_out_seqitem);
            }
        &print_class_end($fh_dst);
    }
#********************************************************************************#
    sub print_class_end
    {
        (my $fh_dst,my $cname,my $baseclass)=@_;
        print $fh_dst "class $cname extends $baseclass;\n";
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub uvm_utils
    {
        (my $fh_dst,my $utils_type,my $classname)=@_;
        print $fh_dst "\t`uvm_$utils_type\_utils($classname)\n");
    }
#********************************************************************************#
    sub print_module_end
    {
        (my $fh_dst)=@_;
        print ($fh_dst "\n");#打印换行
        print $fh_dst "endmodule\n");
    }
#********************************************************************************#
    sub print_class_end
    {
        (my $fh_dst)=@_;
        print ($fh_dst "\n");#打印换行
        print $fh_dst "endclass\n");
    }
#********************************************************************************#
    sub get_dut_clock_and_reset 
    {
        (my $fh_dst)=@_;
        seek($fh_src,0,0);  #回到文件开头
        while(<$fh_src>)
        {
            chomp;
            if(/([gGC]?Clk)/i)
            {
                $clk = $1;
                next;
            }
            elsif(/Reset(?:_n|_N]?))/i)
            {
                $reset = $1;
                next;
            }
        }
    }
#********************************************************************************#
    sub string2replace 
    {
        (my $fh_src,my $fh_dst,my $string,my $replace)=@_;
        seek($fh_src,0,0);  #回到文件开头
        while(<$fh_src>)
        {
            chomp;
            if(/^\s*\/\//)
            {
                next;
            }
            elsif(/$String(.*);/)
            {
                if(/([gGC]?Clk)/i)  #时钟和复位信号不包含在item中
                {
                    $clk = $1;
                    next;
                }
                elsif(/Reset(?:_n|_N]?))/i)
                {
                    $reset = $1;
                    next;
                }
                print $fh_dst "\t$replace$1;","\n";
            }
        }
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
    }
#********************************************************************************#
    sub uvm_field_declare #设置域声明
    {
       (my $fh_src,my $fh_dst,my $in_out,my $classname)=@_;
        seek($fh_src,0,0);  #回到文件开头
        print $fh_dst "\t`uvm_object_utils_begin($classname)","\n";
        while(<$fh_src>)
        {
            chomp;
            if(/^\s*\/\//)  #注释，跳过
            {next;}
            elsif(/$in_out.*\s+(\w+)\s*;/)
            {
                if(/Reset|Clk/)
                {
                    next;
                }
                print $fh_dst "\t\t`uvm_field_int($1,UVM_ALL_ON","\n";
            }
        }
        print $fh_dst "\t`uvm_object_utils_end","\n";
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
    }
#********************************************************************************#
    #设置基本约束
    sub set_base_cons
    {
       (my $fh_src,my $fh_dst)=@_;
        print $fh_dst "\t`constraints c1 {","\n";
        seek($fh_src,0,0);  #重新将文件指针放在文件开头
        while(<$fh_src>)
        {   
            chomp;
            if(/Reset|Clk/) #时钟和复位不包含在item中
            {
                next; 
            }
            elsif(/input\s+(\w+)\s*;/)  #信号位宽为1 
            {
                printf($fh_dst "\t\t\t\t\t%-30s\t\t%-100s\n",$1,"inside {[0:1]};");
            }
            elsif(/input\s*\[(\d+):(\d+)\]\s+(\w+)\s*;/)  # 信号位宽大于1
            {
                my #power = $1-$2+1;    #求出2的幂 
                printf($fh_dst "\t\t\t\t\t%-30s\t\t%-100s\n",$3,"inside {[0:2**$power-1]};");
            }
        }
        print $fh_dst "\t\t\t\t)","\n";
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
    }
#********************************************************************************#
    sub component_new
    {
       (my $fh_src,my $cname)=@_;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction new(string name = \"$cname\",uvm_component parent);\n");
        print ($fh_dst "\t\tsuper.new(name);\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub object_new
    {
       (my $fh_src,my $cname)=@_;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction new(string name = \"$cname\");\n");
        print ($fh_dst "\t\tsuper.new(name);\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub task_body 
    {
       (my $fh_src,my $instname)=@_;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\ttask body();\n");
        print ($fh_dst "\t//TODO:you can customize your constraints bellow,for example:;\n");
        print ($fh_dst "\tforever\n");
        print ($fh_dst "\t\tbegin\n");
        print ($fh_dst "\t\t\t`uvm_do($instname);\n");
        print ($fh_dst "\t\tend\n");
        print ($fh_dst "\tendtask\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub env_bulid_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction void $c_env\:\:build_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tsuper.build_phase(phase);\n");
        print ($fh_dst "\t\t$i_agt1 = $c_agt:\:type_id::create(i\"$i_agt1\",this);\n");
        print ($fh_dst "\t\t$i_agt2 = $c_agt:\:type_id::create(i\"$i_agt2\",this);\n");
        print ($fh_dst "\t\t$i_agt1.is_active = UVM_ACTIVE;\n");
        print ($fh_dst "\t\t$i_agt2.is_active = UVM_PASSIVE;\n");
        print ($fh_dst "\t\t$i_mdl = $c_mdl:\:type_id::create(i\"$i_mdl\",this);\n");
        print ($fh_dst "\t\t$i_scb = $c_scb:\:type_id::create(i\"$i_scb\",this);\n");
        print ($fh_dst "\t\t$agt_mdl_fifo = new(\"$agt_mdl_fifo\",this);\n");
        print ($fh_dst "\t\t$agt_scb_fifo = new(\"$agt_scb_fifo\",this);\n");
        print ($fh_dst "\t\t$mdl_scb_fifo = new(\"$mdl_scb_fifo\",this);\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub env_connect_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction void $c_env\:\:connect_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tsuper.connect_phase(phase);\n");
        print ($fh_dst "\t\t$i_agt1.$i_drv_ap.connect($agt_mdl_fifo.analysis_export);\n");
        print ($fh_dst "\t\t$i_mdl.port.connect($agt_mdl_fifo.blocking_get_export;\n");
        print ($fh_dst "\t\t$i_mdl.ap.connect($mdl_scb_fifo.analysis_export;\n");
        print ($fh_dst "\t\t$i_scb.export.connect($mdl_scb_fifo.blocking_get_export;\n");
        print ($fh_dst "\t\t$i_agt2.$i_mon_ap.connect($agt_scb_fifo.analysis_export);\n");
        print ($fh_dst "\t\t$i_scb.act_port.connect($agt_scb_fifo.blocking_get_export;\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub test_start_of_simulation_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction void $c_base_test\:\:start_of_simulation_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tsuper.start_of_simulation_phase(phase);\n");
        print ($fh_dst "\t\tuvm_top.print_topology();\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub test_report_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction void $c_base_test\:\:report_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tuvm_report_server server;\n");
        print ($fh_dst "\t\tint err_num;\n");
        print ($fh_dst "\t\tsuper.report_phase(phase);\n");
        print ($fh_dst "\t\tserver = get_report_server();\n");
        print ($fh_dst "\t\terr_num = server.get_severity_count(UVM_ERROR);\n");
        print ($fh_dst "\t\tif(err_num !=0);\n");
        print ($fh_dst "\t\tbegin\n");
        print ($fh_dst "\t\t\$display(\"TEST CASE FAILED !!!\");\n");
        print ($fh_dst "\t\tend\n");
        print ($fh_dst "\t\telse\n");
        print ($fh_dst "\t\tbegin\n");
        print ($fh_dst "\t\t\$display(\"TEST CASE PASSED ^_^ \");\n");
        print ($fh_dst "\t\tend\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub driver_main_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\ttask $c_drv\:\:main_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tREQ tmp;\n");
        print ($fh_dst "\t\t$c_in_seqitem exp_item;\n");
        print ($fh_dst "\t\tforever;\n");
        print ($fh_dst "\t\tbegin\n");
        print ($fh_dst "\t\t\tseq_item_port.get_next_item(tmp);\n");
        print ($fh_dst "\t\t\t\$cast(exp_item,tmp);\n");
        print ($fh_dst "\t\t\tdrive_one_item(exp_item);\n");
        print ($fh_dst "\t\t\tseq_item_port.item_done();\n");
        print ($fh_dst "\t\t\tap.write.(exp_item);\n");
        print ($fh_dst "\t\tend\n");
        print ($fh_dst "\tendtask\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub monitor_main_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\ttask $c_mon\:\:main_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\t$c_out_seqitem tr;\n");
        print ($fh_dst "\t\tforever;\n");
        print ($fh_dst "\t\tbegin\n");
        print ($fh_dst "\t\t\ttr=new(\"tr\");\n");
        print ($fh_dst "\t\t\tcollect_one_item(tr);\n");
        print ($fh_dst "\t\t\tap.write.(tr);\n");
        print ($fh_dst "\t\tend\n");
        print ($fh_dst "\tendtask\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub model_main_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\ttask $c_mdl\:\:main_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\t$c_in_seqitem tr;\n");
        print ($fh_dst "\t\t$c_out_seqitem new_tr;\n");
        print ($fh_dst "\t\tsuper.main_phase(phase);\n");
        print ($fh_dst "\t\tforever;\n");
        print ($fh_dst "\t\tbegin\n");
        print ($fh_dst "\t\t\ttr=new(\"tr\");\n");
        print ($fh_dst "\t\t\tnew_tr=new(\"new_tr\");\n");
        print ($fh_dst "\t\t\tport.get(tr);\n");
        print ($fh_dst "\t\t\tnew_tr.copy(tr);\n");
#       print ($fh_dst "\t\t\t`uvm_info(\"$c_mdl\",\"get one transaction,copy and print it\",UVM_LOW)\n");
#       print ($fh_dst "\t\t\tnew_tr.print();\n");
        print ($fh_dst "\t\t\tap.write(new_tr);\n");
        print ($fh_dst "\t\tend\n");
        print ($fh_dst "\tendtask\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub scoreboard_main_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\ttask $c_scb\:\:main_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\t$c_out_seqitem get_exp,get_act,tmp_trans;\n");
        print ($fh_dst "\t\tsuper.main_phase(phase);\n");
        print ($fh_dst "\t\t`uvm_info(\"$c_scb\",\"scoreboard main_phase is called\",UVM_LOW)\n");
        print ($fh_dst "\tfork;\n");
        print ($fh_dst "\t\tforever;\n");
        print ($fh_dst "\t\tbegin\n");
        print ($fh_dst "\t\t\t$exp_port.get(get_exp);\n");
        print ($fh_dst "\t\t\t$exp_queue.push_back(get_exp);\n");
        print ($fh_dst "\t\tend\n");
        print ($fh_dst "\t\tforever\n");
        print ($fh_dst "\t\tbegin\n");
        print ($fh_dst "\t\t\t`uvm_info(\"$c_scb\",\"scoreboard is running...\",UVM_LOW)\n");
        print ($fh_dst "\t\t\t$act_port.get(get_act);\n");
        print ($fh_dst "\t\tend\n");
        print ($fh_dst "\tjoin\n");
        print ($fh_dst "\tendtask\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub drive_one_item 
    {
        my $fh_dst=shift;
        my $fh_src=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\ttask $c_drv\:\:drive_one_item($c_in_seqitem tr);\n");
        print ($fh_dst "\t\t@(posedge $i_drv_dut_if.$clk)\n");
        print ($fh_dst "\t\tbegin\n");
        seek($fh_src,0,0);  #回到文件开头
        while(<$fh_src>)
        {   
            chomp;
            if(/input.*\s+(\w+)\s*;/)  #信号位宽为1 
            {
                if(/Reset|Clk/) #时钟和复位不包含在item中
                {
                    next; 
                }
                else
                {
                    printf($fh_dst "\t\t\t$i_drv_dut_if.%-30s<=\ttr.%-30s\n",$1,$1);
                }
            }
        }
        print $fh_dst "\t\tend\n");
        print ($fh_dst "\tendtask\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub seq_pre_body 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\ttask $c_demo_seq\:\:pre_body();\n");
        print ($fh_dst "\tif(starting_phase != null)\n");
        print ($fh_dst "\t\tstarting_phase.raise_objection(this);\n");
        print ($fh_dst "\tendtask\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub seq_body 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\ttask $c_demo_seq\:\:body();\n");
        print ($fh_dst "\trepeat(10)\n");
        print ($fh_dst "\tbegin\n");
        print ($fh_dst "\t\tuvm_do($i_in_seqitem)\n");
        print ($fh_dst "\tend\n");
        print ($fh_dst "\tendtask\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
#********************************************************************************#
    sub seq_post_body 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\ttask $c_demo_seq\:\:post_body();\n");
        print ($fh_dst "\tif(starting_phase != null)\n");
        print ($fh_dst "\t\tstarting_phase.drop_objection(this);\n");
        print ($fh_dst "\tendtask\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub collect_one_item 
    {
        (my $fh_dst, my $fh_src)=@_;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\ttask $c_mon\:\:collect_one_item($c_out_seqitem tr);\n");
        print ($fh_dst "\t@(posedge $i_dut_mon_if.$clk);\n");
        print ($fh_dst "\t`uvm_info(\"$c_mon\",\"begin to collect one item\",UVM_LOW)\n");
        print ($fh_dst "\t\tbegin\n");
        seek($fh_src,0,0);  #回到文件开头
        while(<$fh_src>)
        {   
            chomp;
            if(/^\s*\/\//)  #信号位宽为1 
            {next;}
            elsif(/output.*\s+(\w+)\s*;/)
            {
                printf($fh_dst "\t\t\ttr.%-30s =\t$i_dut_mon_if.%-30s;\n",$1,$1);
            }
        }
        print ($fh_dst "\t`uvm_info(\"$c_mon\",\"item_collecting finish,print it:\",UVM_LOW)\n");
        print $fh_dst "\ttr.print()\n");
        print ($fh_dst "\tendtask\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub module_declare 
    {
        (my $fh_dst)=@_;
        print ($fh_dst "import uvm_pkg::*;\n");
        print ($fh_dst "include\"uvm_macros.svh;\n");
        foreach (@uvm_filelist)
        {
            print ($fh_dst "`include\"$_.sv\"\n");
        }
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "module  $m_module;\n");
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub port_declare 
    {
        (my $fh_dst,my $port_type,my $c_in_seqitem,my $port_name) = @_;
        print ($fh_dst "\t$port_type#($c_in_seqitem)\t$port_name;\n");
    }
#********************************************************************************#
    sub class_declare 
    {
        (my $fh_dst,my $c_class,my $i_inst) = @_;
        print ($fh_dst "\t$c_class\t$i_inst;\n");
    }
#********************************************************************************#
    sub interface_declare 
    {
        (my $fh_dst,my $m_module,my $f_interface,my $i_interface) = @_;
        print ($fh_dst "\t$f_interface\t$i_interface($m_module.$clk,$m_module.$reset);\n");
    }
#********************************************************************************#
    sub open_wave 
    {
        (my $fh_dst) = @_;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "initial\n");
        print ($fh_dst "begin\n");
        print ($fh_dst "\t\$shm_open(\"$modulename\.shm\");\n");
        print ($fh_dst "\t\$shm_probe(\"AC\");\n");
        print ($fh_dst "end\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub clock_and_reset 
    {
        (my $fh_dst) = @_;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "reg $clk;\n");
        print ($fh_dst "reg $reset;\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "initial\n");
        print ($fh_dst "begin\n");
        print ($fh_dst "\t$clk=1'b0;\n");
        print ($fh_dst "\tforever #10 $clk=~$clk;\n");
        print ($fh_dst "end\n");
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "initial\n");
        print ($fh_dst "begin\n");
        print ($fh_dst "\t$reset=1'b1;\n");
        print ($fh_dst "\t#10 $reset=1'b0;\n");
        print ($fh_dst "\t#400 $reset=1'b1;\n");
        print ($fh_dst "end\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub dut_instantize 
    {
        my $fh_src=shift;
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\t$m_dut $i_dut \(\n");
        seek($fh_src,0,0); 
        while(<$fh_src>)
        {
            chomp;
            if(/^\s*\/\//)
            {
                next;
            }
            elsif(/input\s*(?:\[.*\])?\s*(\w+)\s*;/)
            {
                print($fh_dst "\t\.$1\($i_drv_dut_if\.$1\),\n");
            }
            elsif(/output\s*(?:\[.*\])?\s*(\w+)\s*;/)
            {
                print($fh_dst "\t\.$1\($i_dut_mon_if\.$1\),\n");
            }
        }
        my $pos = tell($fh_dst);
        my $pos_coma = $pos - 2;
        seek($fh_dst,$pos_coma,0) or die
        print ($fh_dst "\);\n");
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
    }
#********************************************************************************#
    sub interface_connect_and_run_test 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "initial\n");
        print ($fh_dst "begin\n");
        print ($fh_dst "\tuvm_config_db#(virtual $c_drv_dut_if)::set(null,\"uvm_test_top.$i_env.$i_agt1.$i_drv\",\"vif\",$i_drv_dut_if\);\n");
        print ($fh_dst "\tuvm_config_db#(virtual $c_dut_mon_if)::set(null,\"uvm_test_top.$i_env.$i_agt2.$i_mon\",\"vif\",$i_dut_mon_if\);\n");
        print ($fh_dst "\trun_test();\n");
        print ($fh_dst "end\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub demo_test_bulid_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction void $c_demo_test\:\:build_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tsuper.build_phase(phase);\n");
        print ($fh_dst "\t\tuvm_config_db#(uvm_object_wrapper)::set(this,\n");
        print ($fh_dst "\t\t                                         \"$i_env.$i_agt1.$i_sqr.main_phase\",\n");
        print ($fh_dst "\t\t                                         \"default_sequence\",\n");
        print ($fh_dst "\t\t                                         $c_demo_seq\:\:type_id\:\:get());\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub base_test_bulid_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction void $c_base_test\:\:build_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tsuper.build_phase(phase);\n");
        print ($fh_dst "\t\t$i_env = $c_env:\:type_id::create(\"$i_env\",this);\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub driver_bulid_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction void $c_drv\:\:build_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tap=new(\"ap\",this);\n");
        print ($fh_dst "\t\tsuper.build_phase(phase);\n");
        print ($fh_dst "\t\tif(!uvm_config_db#(virtual $c_drv_dut_if)::get(this,\"\",\"vif\",$i_drv_dut_if))\n");
        print ($fh_dst "\t\t\t`uvm_info(\"GETVIF\",\"cannot get $i_drv_dut_if !!!\",UVM_LOW)\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub monitor_bulid_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction void $c_mon\:\:build_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tap=new(\"ap\",this);\n");
        print ($fh_dst "\t\tsuper.build_phase(phase);\n");
        print ($fh_dst "\t\tif(!uvm_config_db#(virtual $c_dut_mon_if)::get(this,\"\",\"vif\",$i_dut_mon_if))\n");
        print ($fh_dst "\t\t\t`uvm_fatal(\"$c_mon\",\"cannot get vif !!!\")\n");
        print ($fh_dst "\t\t`uvm_info(\"$c_mon\",\"$c_mon is called\",UVM_LOW)\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub agent_bulid_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction void $c_agt\:\:build_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tsuper.build_phase(phase);\n");
        print ($fh_dst "\t\t$i_drv_ap=new(\"$i_drv_ap\",this);\n");
        print ($fh_dst "\t\t$i_mon_ap=new(\"$i_mon_ap\",this);\n");
        print ($fh_dst "\t\tif(is_active==UVM_ACTIVE)\n");
        print ($fh_dst "\t\tbegin\n");
        print ($fh_dst "\t\t\t$i_sqr = $c_sqr:\:type_id::create(\"$i_sqr\",this);\n");
        print ($fh_dst "\t\t\t$i_drv = $c_drv\:type_id::create(\"$i_drv\",this);\n");
        print ($fh_dst "\t\tend\n");
        print ($fh_dst "\t\telse\n");
        print ($fh_dst "\t\tbegin\n");
        print ($fh_dst "\t\t\t$i_mon = $c_mon\:type_id::create(\"$i_mon\",this);\n");
        print ($fh_dst "\t\tend\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub model_bulid_phase 
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction void $c_mdl\:\:build_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tsuper.build_phase(phase);\n");
        print ($fh_dst "\t\tport=new(\"port\",this);\n");
        print ($fh_dst "\t\tap=new(\"ap\",this);\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub scoreboard_bulid_phase
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction void $c_scb\:\:build_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tsuper.build_phase(phase);\n");
        print ($fh_dst "\t\t\t`uvm_info(\"$c_scb\",\"scoreboard build_phase is called\",UVM_LOW)\n");
        print ($fh_dst "\t\t$exp_port=new(\"$exp_port\",this);\n");
        print ($fh_dst "\t\t$act_port=new(\"$act_port\",this);\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub agent_connect_phase
    {
        my $fh_dst=shift;
        print ($fh_dst "\n");#打印换行
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\tfunction void $c_agt\:\:connect_phase(uvm_phase phase);\n");
        print ($fh_dst "\t\tsuper.connect_phase(phase);\n");
        print ($fh_dst "\t\tif(is_active==UVM_ACTIVE)\n");
        print ($fh_dst "\t\tbegin\n");
        print ($fh_dst "\t\t\t$i_drv.seq_item_port.connect($i_sqr.seq_item_export);\n");
        print ($fh_dst "\t\t\t$i_drv_ap = $i_drv.ap;\n");
        print ($fh_dst "\t\tend\n");
        print ($fh_dst "\t\telse\n");
        print ($fh_dst "\t\tbegin\n");
        print ($fh_dst "\t\t\t$i_mon_ap = $i_mon.ap;\n");
        print ($fh_dst "\t\tend\n");
        print ($fh_dst "\tendfunction\n");
        print ($fh_dst "/","*" x 80,"\n");#打印分隔符
        print ($fh_dst "\n");#打印换行
    }
#********************************************************************************#
    sub task_func_declare
    {
        my $fh_dst=shift;
        my $task_or_func=shift;
        my $name=shift;
        my $args=shift;
        print ($fh_dst "\textern virtual $task_or_func $name($args);\n");
    }
#********************************************************************************#
