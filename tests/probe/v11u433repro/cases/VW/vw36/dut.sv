// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y;
  logic [7:0] z;
  if (W <= 4) begin: g
    assign y = W % 3 + 1;
    always_comb z = W + 1;
  end
endmodule
