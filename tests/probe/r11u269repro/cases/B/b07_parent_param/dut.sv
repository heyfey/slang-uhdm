// § caLhsBindsUpScopes269 (control: the parent declares the name as a parameter, not a net)
module m #(parameter int W = 4) (output wire [3:0] o);
  if (1) begin : g
    wire [3:0] pp;
    assign pp = {W{1'b1}};
  end
  assign o = g.pp;
endmodule
module top #(parameter int pp = 2) (output wire [3:0] o);
  m u(.o(o));
endmodule
