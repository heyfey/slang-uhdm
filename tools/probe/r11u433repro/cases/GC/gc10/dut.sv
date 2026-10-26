// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, output [15:0] z);
  logic [3:0] a;
  if (W > 1) begin: g
    assign y = W + a;
    assign {z[15:8], z[7:0]} = W + 1;
  end
endmodule
