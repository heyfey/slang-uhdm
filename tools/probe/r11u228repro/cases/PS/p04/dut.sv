// § parseViewSizeExprEval228 — a generate-for block and a nested instance with two parameter values
module sub #(parameter int N = 2) (output logic [7:0] o);
  bit [N-1:0][2:0] bq;
  for (genvar k = 0; k < 2; k++) begin : g
    wire [7:0] w = $size(bq);
  end
  assign o = g[1].w;
endmodule
module dut (output logic [7:0] o1, o2);
  sub #(.N(3)) u1 (.o(o1));
  sub #(.N(6)) u2 (.o(o2));
endmodule
