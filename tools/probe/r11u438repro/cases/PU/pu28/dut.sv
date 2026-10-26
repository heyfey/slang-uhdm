// § caPlainLhsUnsizedClone438
program prg(input [15:0] b, output y);
  assign y = b['hA];
endprogram
module top(input [15:0] b, output y);
  prg p(.b(b), .y(y));
endmodule
