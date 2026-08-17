package pg1;
  class k1;
    int mv;
    extern function int r_plain();
    extern function int r_sized();
    extern function int r_paren();
    extern function int r_space();
    extern function int r_bit();
    extern function int r_real();
    extern function int r_based();
    extern function int r_var();
    extern function int r_dbl();
    extern function int r_uplus();
    extern function int r_tilda();
    extern function int r_add();
    extern function int r_hex();
    extern function void a_asgn();
    extern function void a_decl();
    extern function void a_arg();
    extern function int a_cmp(int x);
    extern function void a_case(int x);
    extern task t_asgn();
  endclass
  function int k1::r_plain(); return -1; endfunction
  function int k1::r_sized(); return -8'd3; endfunction
  function int k1::r_paren(); return -(1); endfunction
  function int k1::r_space(); return - 1; endfunction
  function int k1::r_bit(); return -1'b1; endfunction
  function int k1::r_real(); return -1.5; endfunction
  function int k1::r_based(); return -'d1; endfunction
  function int k1::r_var(); return -mv; endfunction
  function int k1::r_dbl(); return -(-1); endfunction
  function int k1::r_uplus(); return +1; endfunction
  function int k1::r_tilda(); return ~1; endfunction
  function int k1::r_add(); return 1 - 2; endfunction
  function int k1::r_hex(); return -'h10; endfunction
  function void k1::a_asgn();
    int a;
    a = -1;
    mv = -2;
  endfunction
  function void k1::a_decl();
    int b = -1;
  endfunction
  function void k1::a_arg();
    $display("%0d", -1);
  endfunction
  function int k1::a_cmp(int x);
    if (x == -1) return 1;
    return 0;
  endfunction
  function void k1::a_case(int x);
    case (x)
      -1: mv = 1;
      default: mv = 0;
    endcase
  endfunction
  task k1::t_asgn();
    mv = -1;
  endtask
endpackage
