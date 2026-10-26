// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  assign y = b['hA] ;
endmodule
module mid(input [15:0] b, output y);
  sub s(.b(b), .y(y));
endmodule
module top(input [15:0] b, output y);
  mid m(.b(b), .y(y));
endmodule
