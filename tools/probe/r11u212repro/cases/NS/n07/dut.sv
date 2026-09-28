// § signCastSysCallLhsTs212 — the signing cast as a continuous assignment inside a generate block
module dut (input logic [9:0] i, output logic [6:0] o);
  if (1) begin : g
    wire signed [6:0] v;
    assign v = signed'(i[6:0]);
  end
  assign o = g.v;
endmodule
