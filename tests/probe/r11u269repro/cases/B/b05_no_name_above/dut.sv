// § caLhsBindsUpScopes269 (control: the gen-local name is declared nowhere above, the parent stays)
module m #(parameter int W = 4) (output wire [3:0] o);
  if (1) begin : g
    wire [3:0] q1;
    assign q1 = {W{1'b1}};
  end
  assign o = g.q1;
endmodule
module top(output wire [3:0] o);
  m u(.o(o));
endmodule
