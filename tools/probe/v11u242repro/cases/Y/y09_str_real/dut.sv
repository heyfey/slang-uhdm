// § impArrParamTsOwnRanges242
// A string array and a real array imported by a module.
package hp;
  parameter string S [2] = '{"a", "bc"};
  parameter real R [2] = '{1.0, 2.5};
  parameter int A [2] = '{3, 4};
endpackage
module core import hp::*; (input logic i, output int o);
  assign o = A[i];
endmodule
module top (input logic i, output int o);
  core u (.i(i), .o(o));
endmodule
