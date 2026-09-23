typedef logic [2:0] w_t;
module leaf #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module mid #(parameter type U = logic) (input logic [5:0] a, output logic o);
  leaf #(.T(U [1:0])) l (.a(a), .o(o));
endmodule
module dut (input logic [5:0] a, output logic o);
  mid #(.U(w_t)) m (.a(a), .o(o));
endmodule
