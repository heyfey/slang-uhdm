// § caLhsBindsUpScopes269
module m #(parameter int W = 4) (output wire [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    wire [3:0] q;
    assign q = {W{1'b0}};
  end
  assign o = g[0].q;
endmodule
module top(output wire [3:0] o);
  m u(.o(o));
  wire [3:0] q = 4'h1;
endmodule
