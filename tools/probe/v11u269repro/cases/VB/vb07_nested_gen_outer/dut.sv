// § caLhsBindsUpScopes269
module m #(parameter int W = 4) (output wire [3:0] o);
  if (1) begin : g
    wire [3:0] w;
    if (1) begin : h
      wire [3:0] w;
      assign w = {W{1'b1}};
    end
    assign w = h.w;
  end
  assign o = g.w;
endmodule
module top(output wire [3:0] o);
  m u(.o(o));
endmodule
