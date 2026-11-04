// § typeParamStructLastNetParent273
module dut (input logic [4:0] i, output logic [4:0] o);
  localparam type T = struct packed { logic [3:0] a; logic b; };
  T s;
  T t;
  always_comb s = i;
  assign t = s;
  assign o = t;
endmodule
