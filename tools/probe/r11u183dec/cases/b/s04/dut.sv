package p;
  typedef struct packed {
    int unsigned a;
    bit flag1;
  } ucfg_t;
  function automatic int unsigned geta(input ucfg_t u);
    return u.a;
  endfunction
endpackage
module top #(parameter p::ucfg_t U = '{a: 7, flag1: 1'b1}) (output int unsigned o);
  assign o = p::geta(U);
endmodule
