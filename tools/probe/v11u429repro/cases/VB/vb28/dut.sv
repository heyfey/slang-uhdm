// § genBodyBitsOuterNameKeeps429
module top (y);
  output [7:0] y;
  reg [7:0] y;
  wire [5:0] w;
  generate if (1) begin: g
    always @* y = $bits(w);
  end endgenerate
endmodule
