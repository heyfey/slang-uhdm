// § caLhsBindsUpScopes269 (a generate block nested in another, the module declares the name)
module m #(parameter int W = 4) (output wire [3:0] o);
  wire [3:0] nn;
  if (1) begin : g
    if (1) begin : h
      wire [3:0] nn;
      assign nn = {W{1'b1}};
    end
  end
  assign o = g.h.nn | nn;
endmodule
module top(output wire [3:0] o);
  m u(.o(o));
endmodule
