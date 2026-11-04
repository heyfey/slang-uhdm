// § ndaWholeSysCallSharesLhs428
module top(input [3:0] x);
  wire b = $onehot(x);
  wire c = $isunknown(x);
endmodule
