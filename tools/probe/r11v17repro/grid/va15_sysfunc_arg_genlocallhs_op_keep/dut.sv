// The landed law's OWN population: a GEN-LOCAL Lhs, which bindVariable never
// finds, so the re-bind must STILL fire.
module top(input logic [15:0] a, input logic p, output logic [33:0] o);
  logic sa;
  if (1) begin : gb
    logic [15:0] oa;
    logic signed [33:0] res;
    assign oa = a;
    assign sa = p;
    assign res = $signed({sa, oa}) * 34'sd3;
    assign o = res;
  end
endmodule
