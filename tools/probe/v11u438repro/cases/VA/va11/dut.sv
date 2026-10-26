// § caPlainLhsUnsizedClone438
module sub(output y);
  logic [3:0] v = 4'h5;
  assign y = v['h2];
endmodule
module top(output y);
  sub u(.y(y));
endmodule
