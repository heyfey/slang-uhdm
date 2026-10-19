// § sizeTickSpaceDropped403
module top;
  logic [7:0] a, b, c;
  initial begin
    a = 8 'sd 3;
    b = 4 'b1010;
    c = 8  'hF_F;
  end
endmodule
