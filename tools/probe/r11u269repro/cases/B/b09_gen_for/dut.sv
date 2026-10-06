// § caLhsBindsUpScopes269 (a for-generate block, the name declared by the parent)
module m #(parameter int W = 2) (output wire [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    wire [1:0] w2;
    assign w2 = {W{1'b1}};
    assign o[i*2 +: 2] = w2;
  end
endmodule
module top(output wire [3:0] o);
  wire [1:0] w2;
  m u(.o(o));
  assign w2 = o[1:0];
endmodule
