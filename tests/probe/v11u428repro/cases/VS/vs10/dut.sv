// § ndaWholeSysCallSharesLhs428
module top(input real r, output [63:0] o);
  wire [63:0] w = $realtobits(r);
  assign o = w;
endmodule
