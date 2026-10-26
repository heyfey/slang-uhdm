// § genCaAddParamIntCt435
module child #(parameter W = 2) (output [7:0] y);
  if (1) begin: g
    assign y = W + 1;
  end
endmodule
module top;
  wire [7:0] a;
  child u(a);
  defparam u.W = 4'd4;
endmodule
