// § signCastSysCallLhsTs212 — the signing cast onto a select target (not a whole name)
module dut (input logic [9:0] i, output logic [7:0] o);
  logic signed [7:0] v;
  assign v[6:0] = signed'(i[6:0]);
  assign v[7] = 1'b0;
  assign o = v;
endmodule
