package pk;
  typedef logic [1:0] w_t;
endpackage
module child #(parameter type T = logic) (input T a, output int n);
  assign n = $bits(T);
endmodule
module dut (input logic [11:0] a, output int n);
  child #(pk::w_t [1:0][2:0]) u (.a(a), .n(n));
endmodule
