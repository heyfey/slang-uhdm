// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y);
  logic [7:0] v;
  int iv;
  if (W > 1) begin: g
    always_comb iv = W + 1;
    assign v = W + 1;
  end
  assign y = v;
endmodule
