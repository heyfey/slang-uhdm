typedef logic [1:0] w_t;
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [7:0] a, output logic o, output logic p);
  child #(.T(w_t [3:0])) u (.a(a), .o(o));
  child #(.T(w_t)) v (.a(a[1:0]), .o(p));
endmodule
