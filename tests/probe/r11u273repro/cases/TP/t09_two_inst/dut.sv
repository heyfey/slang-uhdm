// § typeParamStructLastNetParent273
module m #(parameter type T = struct packed { logic [3:0] a; logic b; }) (input logic [4:0] i, output logic [4:0] o);
  T s;
  always_comb s = i;
  assign o = s;
endmodule
module dut(input logic [4:0] i, output logic [4:0] o1, output logic [4:0] o2);
  m u1(.i(i), .o(o1));
  m u2(.i(i), .o(o2));
endmodule
