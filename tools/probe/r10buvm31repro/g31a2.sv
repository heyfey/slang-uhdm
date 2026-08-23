package q31;
  class k31;
     int cs_dyn[]   = '{1,2,3};
     int cs_que[$]  = '{4,5};
     int cc_dyn[]   = {6,7,8};
     int cc_que[$]  = {9};
     int cr_dyn[]   = '{3{2}};
     byte cb_dyn[]  = '{1,2};
     int cf_fix[3]  = '{1,2,3};
     int cfd_fix[3] = '{default:9};
     int ca_two[string][string] = '{default:0};
     int ca_intk[int] = '{3:1, 4:2};
  endclass
  int ps_dyn[]  = '{1,2,3};
  int pc_dyn[]  = {6,7,8};
  int pd_que[$] = '{default:0};
  int pd_dyn[]  = '{default:1};
endpackage

module m31;
  int ms_dyn[]  = '{1,2,3};
  int mc_dyn[]  = {6,7,8};
  int md_que[$] = '{default:0};
  int md_dyn[]  = '{default:1};
  int md_aa[string] = '{default:2};
  int mf_fix[3] = '{default:9};
  initial $display("%p%p%p%p%p%p", ms_dyn, mc_dyn, md_que, md_dyn, md_aa, mf_fix);
endmodule
