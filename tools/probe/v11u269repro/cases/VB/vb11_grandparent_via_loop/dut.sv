// § caLhsBindsUpScopes269
module m #(parameter int W = 4) (output wire [3:0] o);
  if (1) begin : g
    wire [3:0] w;
    assign w = {W{1'b1}};
  end
  assign o = g.w;
endmodule
module mid(output wire [3:0] o);
  m u(.o(o));
endmodule
module top(output wire [7:0] o);
  logic [3:0] w;
  for (genvar i = 0; i < 2; i++) begin : gl
    mid um(.o(o[i*4 +: 4]));
  end
endmodule
