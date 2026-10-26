// § caPlainLhsUnsizedClone438
module sub #(parameter W = 8) (input [W-1:0] b, output y);
  assign y = b['h2];
endmodule
module top(input [15:0] b, output y, z);
  sub #(.W(16)) u(.b(b), .y(y));
  sub #(.W(4)) v(.b(b[3:0]), .y(z));
endmodule
