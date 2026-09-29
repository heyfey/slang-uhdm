// § tfArgScalarTdWriter223
package p;
  typedef logic L1;
  typedef reg [3:0] R4;
  typedef logic signed [7:0] LS8;
  typedef bit signed [7:0] BS8;
  typedef int unsigned IU;
  class c;
    function void f(L1 a, R4 b, LS8 c2, BS8 d, IU e);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  L1 f;
endmodule
