package p31;

  class c31;
     protected int q_str[string]  = '{default:0};
     int q_int[int] = '{default:0};
     int q_nz[string] = '{default:7};
     bit [7:0] q_bv[string] = '{default:0};
     int q_key[string] = '{"a":1, "b":2};
     int q_dyn[] = '{default:0};
     int q_que[$] = '{default:0};
     string q_strv[string] = '{default:"x"};
  endclass

  int m_str[string] = '{default:0};
  int m_key[string] = '{"a":1};

endpackage

module top31;
  int t_str[string] = '{default:0};
  class d31;
    local int r_str[string] = '{default:3};
    static int s_str[string] = '{default:4};
    rand int rd_str[string] = '{default:5};
  endclass
  d31 d = new;
  initial $display("%p", t_str);
endmodule
