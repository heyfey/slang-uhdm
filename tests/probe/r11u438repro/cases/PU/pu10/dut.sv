// § caPlainLhsUnsizedClone438 (control: 'b1 is sized)
module sub(input [15:0] b, output y);
  assign y = b['b1];
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
