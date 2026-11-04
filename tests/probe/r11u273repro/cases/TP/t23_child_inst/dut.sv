// § typeParamStructLastNetParent273
module m #(parameter type T = struct packed { logic [3:0] a; logic b; }) (input logic [4:0] i, output logic [4:0] o);
  T sv;
  always_comb sv = i;
  assign o = sv;
endmodule
module dut(input logic [4:0] i, output logic [4:0] o1);
  m u1(.i(i), .o(o1));
endmodule
