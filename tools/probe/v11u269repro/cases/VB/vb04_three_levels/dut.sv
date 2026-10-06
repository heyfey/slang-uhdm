// § caLhsBindsUpScopes269
module m #(parameter int W = 4) (output wire [3:0] o);
  if (1) begin : g
    wire [3:0] zz;
    assign zz = {W{1'b1}};
  end
  assign o = g.zz;
endmodule
module mid(output wire [3:0] o);
  m u(.o(o));
endmodule
module top(output wire [3:0] o);
  logic [3:0] zz;
  mid um(.o(o));
endmodule
