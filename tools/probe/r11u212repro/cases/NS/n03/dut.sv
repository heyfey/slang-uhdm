// § signCastSysCallLhsTs212 — control: the same cast as a continuous assignment to a declared net
module dut (input logic [9:0] i, output logic [6:0] o);
  wire signed [6:0] v;
  assign v = signed'(i[6:0]);
  assign o = v;
endmodule
