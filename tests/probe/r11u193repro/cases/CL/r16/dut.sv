// § connSysCallArgDefNet193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [3:0] i, input logic [3:0] j, output logic [7:0] o);
  logic [6:0] r, q;
  assign r = {3'b0, i};
  assign q = {3'b0, j};
  sub u (.d(q ^ signed'(r)), .o(o));
endmodule
