// § tpVarSigKeepsTpParent273v
module m #(parameter type T = union packed { logic [7:0] a; logic [7:0] b; }) (input logic [7:0] i, output logic [7:0] o);
  T u;
  always_comb u = i;
  assign o = u.a;
endmodule
module dut (input logic [7:0] i, output logic [7:0] o1, output logic [7:0] o2);
  m u1(.i(i), .o(o1));
  m u2(.i(i), .o(o2));
endmodule
