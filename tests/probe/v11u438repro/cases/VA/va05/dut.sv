// § caPlainLhsUnsizedClone438
module leaf(input [7:0] b, output y);
  assign y = b['h4];
endmodule
module mid(input [7:0] b, output [1:0] y);
  leaf l0(.b(b), .y(y[0]));
  leaf l1(.b(~b), .y(y[1]));
endmodule
module top(input [7:0] b, output [1:0] y);
  mid m(.b(b), .y(y));
endmodule
