// § caPlainLhsUnsizedClone438
module sub(output y);
  wire [3:0] c = 4'h5;
  assign y = c['h1];
endmodule
module top(output y);
  sub u(.y(y));
endmodule
