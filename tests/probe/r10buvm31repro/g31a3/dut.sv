package r31;
  class w31;
     protected int aa_str[string] = '{default:0};
     local int aa_int[int]        = '{default:0};
     int aa_nz[string]            = '{default:7};
     bit [7:0] aa_bv[string]      = '{default:0};
     int aa_key[string]           = '{"a":1, "b":2};
     int dq_dyn[]                 = '{default:0};
     int dq_que[$]                = '{default:0};
     string sv_str[string]        = '{default:"x"};
     static int st_str[string]    = '{default:4};
     rand int rd_str[string]      = '{default:5};
     int two_aa[string][string]   = '{default:0};
  endclass
endpackage

module t31;
  int m_aa[string]  = '{default:0};
  int m_que[$]      = '{default:1};
  int m_dyn[]       = '{default:2};
  int m_sim[]       = '{1,2,3};
  byte m_byte[]     = '{1,2};
  int m_cat[]       = {6,7,8};
  initial $display("%p%p%p%p%p%p", m_aa, m_que, m_dyn, m_sim, m_byte, m_cat);
endmodule
