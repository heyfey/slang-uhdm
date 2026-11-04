// § clsScopedBoundWholeSpan201
class K;
  localparam int V = 5;
  localparam int W = 2;
endclass
module c03 (input logic clk, input logic [31:0] x, output logic [31:0] y);
  logic [31:0] r;
  always_ff @(posedge clk) begin
    r[K::V:K::W] <= x[K::V-1:K::W-1];
    r[K::V+1 +: 2] <= x[1:0];
  end
  function automatic logic [31:0] f(input logic [31:0] a);
    f = a[K::V:K::W];
  endfunction
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[K::V+i*8:K::W+i*8] = f(x) ;
  end
endmodule
