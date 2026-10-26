// § genCaConstRhsWhole433
module top #(parameter W = 2, parameter D = 1) (output [3:0] y);
  logic [7:0] x;
  if (W <= 4) begin: g
    assign #D y[1:0] = W - 1;
  end
endmodule
