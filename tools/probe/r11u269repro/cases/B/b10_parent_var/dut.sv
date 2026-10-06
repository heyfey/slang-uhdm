// § caLhsBindsUpScopes269 (the parent declares the name as a variable)
module m #(parameter int W = 4) (output wire [3:0] o);
  if (1) begin : g
    wire [3:0] lv;
    assign lv = {W{1'b1}};
  end
  assign o = g.lv;
endmodule
module top(output logic [3:0] o);
  logic [3:0] lv;
  m u(.o(lv));
  assign o = lv;
endmodule
