// § caLhsBindsUpScopes269 (v11u267repro VB/vb01)
module m #(parameter int W = 4) (output wire [3:0] x);
  if (1) begin : g
    wire [3:0] x;
    assign x = {W{1'b1}};
  end
  assign x = g.x;
endmodule
module top(output wire [3:0] o);
  m u(.x(o));
endmodule
