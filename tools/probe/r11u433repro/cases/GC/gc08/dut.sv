// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, output [1:0] t);
  if (W > 1) begin: g
    wire [3:0] loc;
    assign loc = W + 1;
    assign y = loc;
    assign t = W + 2;
  end
endmodule
