// § caLhsBindsUpScopes269 (the name only the grandparent instance declares)
module m #(parameter int W = 4) (output wire [3:0] o);
  if (1) begin : g
    wire [3:0] gp;
    assign gp = {W{1'b1}};
  end
  assign o = g.gp;
endmodule
module mid(output wire [3:0] o);
  m u(.o(o));
endmodule
module top(output wire [3:0] o);
  wire [3:0] gp;
  mid um(.o(gp));
  assign o = gp;
endmodule
