// § parseViewSizeExprEval228 — the net width a child parameter, two instances of different widths
module sub #(parameter int W = 4) (output logic [7:0] o);
  bit [W-1:0][2:0] bq;
  wire [W-1:0] w = $size(bq);
  assign o = 8'(w);
endmodule
module dut (output logic [7:0] o1, o2);
  sub #(.W(3)) u1 (.o(o1));
  sub #(.W(6)) u2 (.o(o2));
endmodule
