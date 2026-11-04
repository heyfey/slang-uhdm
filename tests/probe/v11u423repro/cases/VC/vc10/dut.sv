// § clsTfOpFoldTsLate423
package p;
  typedef int i_t;
  parameter i_t A = 1 << 3;
  typedef bit [7:0] b_t;
  parameter b_t B = 8'hA0;
endpackage
module top(input int x, output int y);
  import p::*;
  function automatic int f(int a);
    case (a)
      A: return a & B;
    endcase
    return a + A;
  endfunction
  assign y = f(x);
endmodule
