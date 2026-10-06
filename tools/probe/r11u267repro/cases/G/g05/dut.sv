// § genCaReplParentBoundLhs267
module m (output wire [5:0] o, output logic [5:0] q);
  logic [5:0] v;
  if (1) begin : g
    assign o = {3{2'b01}};
    assign v = {6{1'b1}};
  end
  assign q = v;
endmodule
module top(output wire [5:0] o, output logic [5:0] q);
  m u(.o(o), .q(q));
endmodule
