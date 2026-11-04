// § genCaAddParamIntCt435
module child #(parameter W = 2) (output [7:0] y);
  if (1) begin: g
    assign y = W + 1;
  end
endmodule
module top #(parameter PW = 4'd4) ();
  wire [7:0] a, b;
  child #(.W(PW)) u(a);
  child #(.W(PW + 1)) v(b);
endmodule
