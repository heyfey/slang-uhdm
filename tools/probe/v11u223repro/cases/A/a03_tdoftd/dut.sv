// § tfArgScalarTdWriter223
package p;
  typedef int A_T;
  typedef A_T B_T;
  class c;
    function void f1(B_T x);
    endfunction
    function void f2(A_T y);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  B_T f;
endmodule
