package pkg;
  typedef int i_t;
endpackage
module top(output int o);
  pkg::i_t a = 3;
  assign o = a;
endmodule
