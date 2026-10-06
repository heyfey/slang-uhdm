// § caLhsBindsUpScopes269
module m #(parameter int W = 4) (output wire [3:0] o);
  if (1) begin : g
    wire [3:0] w;
    assign w = {W{1'b1}};
  end
  assign o = g.w;
endmodule
module mid(output wire [3:0] w);
  m u(.o(w));
endmodule
module top(output wire [3:0] o);
  mid um(.w(o));
endmodule
