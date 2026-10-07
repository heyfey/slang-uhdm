// § typeParamStructLastNetParent273
module dut (input logic [3:0] i, output logic [4:0] o);
  localparam type T = struct packed { logic [3:0] a; logic b; };
  T s;
  assign s.a = i;
  assign s.b = 1'b0;
  assign o = s;
endmodule
