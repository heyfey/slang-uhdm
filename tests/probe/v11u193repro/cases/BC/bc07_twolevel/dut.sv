// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module mid (input logic [3:0] a, output logic [7:0] o);
  logic [3:0] r;
  assign r = a;
  sub u (.d(7'(r)), .o(o));
endmodule
module dut (input logic [3:0] a, output logic [7:0] o);
  mid m (.a(a), .o(o));
endmodule
