// § genCaReplParentBoundLhs267
module m #(parameter int W = 4) (output wire [3:0] o);
  if (1) begin : g
    wire [3:0] zz;
    assign zz = {W{1'b1}};
  end
  assign o = g.zz;
endmodule
module top(output wire [3:0] o);
  wire [3:0] zz;
  m u(.o(zz));
  assign o = zz;
endmodule
