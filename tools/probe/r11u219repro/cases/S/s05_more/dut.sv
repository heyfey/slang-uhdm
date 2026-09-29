// § ndaSizeFoldReach219 — declined and folded neighbours: a queue, a parameter operand, a dimension argument in a generate block and a macro-written call
`define SZ(x, d) $size(x, d)
module dut #(parameter logic [7:0] P [3] = '{1, 2, 3}) (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3, output logic [7:0] o4);
  int         q [$];
  logic [2:0] m [4][5];
  wire [7:0] w1 = $size(P);
  wire [7:0] w2 = `SZ(m, 2);
  if (1) begin : g
    wire [3:0] w3 = $size(m, 1);
    assign o3 = 8'(w3);
  end
  assign o1 = w1;
  assign o2 = w2;
  assign o4 = 8'(q.size());
endmodule
