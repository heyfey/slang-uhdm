// § caLhsBindsUpScopes269 (v11u267repro VB/vb02)
module m #(parameter int W = 4) (output wire [3:0] o);
  if (1) begin : g
    wire [3:0] w;
    assign w = {W{1'b1}};
  end
  assign o = g.w;
endmodule
module top(output wire [3:0] o);
  wire [3:0] w;
  m u(.o(w));
  assign o = w;
endmodule
