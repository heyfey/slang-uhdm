// § signCastSysCallLhsTs212 — the signing cast as a continuous assignment in a child instantiated twice
module sub (input logic [9:0] i, output logic signed [6:0] o);
  assign o = signed'(i[6:0]);
endmodule
module dut (input logic [9:0] i, output logic [6:0] o1, output logic [6:0] o2);
  sub u1 (.i(i), .o(o1));
  sub u2 (.i(~i), .o(o2));
endmodule
