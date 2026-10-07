// § typeParamStructLastNetParent273
module m #(parameter int W = 3, parameter type T = struct packed { logic [W-1:0] a; logic b; }) (input logic [W:0] i, output logic [W:0] o);
  T s;
  always_comb s = i;
  assign o = s;
endmodule
module dut (input logic [3:0] i, output logic [3:0] o, input logic [5:0] j, output logic [5:0] p);
  m u0(.i(i), .o(o));
  m #(.W(5)) u1(.i(j), .o(p));
endmodule
