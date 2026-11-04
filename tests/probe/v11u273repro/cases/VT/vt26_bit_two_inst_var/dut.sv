// § tpVarSigKeepsTpParent273v
module m #(parameter type T = struct packed { bit [3:0] a; bit b; }) (input logic [4:0] i, output logic [4:0] o);
  var T s;
  always_comb s = i;
  assign o = s;
endmodule
module dut (input logic [4:0] i, output logic [4:0] o1, output logic [4:0] o2);
  m u1(.i(i), .o(o1));
  m u2(.i(i), .o(o2));
endmodule
