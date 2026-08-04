package p;
  class base;
    typedef enum int { E0 = 0, E1 = 1 } e_t;
    localparam int LP = 7;
    parameter int PP = 8;
    static int sv;
    static const int CI = 9;
  endclass
  class gen #(type T = int);
    static int gsv;
  endclass
  class holder;
    int r;
    function void go();
      r = base::sv;
      r = base::LP;
      r = base::PP;
      r = base::CI;
      r = int'(base::E1);
      r = gen#(int)::gsv;
      r = p::base::sv;
    endfunction
  endclass
endpackage

module top;
  import p::*;
  int z;
  initial begin
    z = base::sv;
    z = base::LP;
  end
endmodule
