// § modUnpackedDimArithRef405
package p; parameter int N = 3; endpackage
module top import p::*; #(parameter int a [N-1:0] = '{default: 1}) (output int o);
  assign o = a[0];
endmodule
