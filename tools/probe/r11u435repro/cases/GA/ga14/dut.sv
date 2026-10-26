// § genCaAddParamIntCt435
module child #(parameter W = 2) (output [7:0] y);
  if (W <= 4) begin: g
    assign y = W + 1;
  end
endmodule
module top;
  wire [7:0] a, b, c;
  child #(.W(3)) u1(a);
  child #(.W(4'd4)) u2(b);
  child #(.W(2*2)) u3(c);
endmodule
