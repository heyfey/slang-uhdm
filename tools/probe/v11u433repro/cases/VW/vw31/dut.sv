// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y;
  wire [7:0] a, b;
  if (W <= 4) begin: g
    assign {a, b} = W + 1;
    assign y[3:0] = W * 5;
    assign y[7:4] = W - 1;
  end
endmodule
