// § tfArgScalarTdWriter223
package p1;
  typedef int T;
  class c1;
    function void f(T x);
    endfunction
  endclass
endpackage
package p2;
  import p1::*;
  typedef byte T;
  class c2 extends c1;
    function void g(T y);
    endfunction
  endclass
endpackage
module top;
  import p2::*;
  T f;
endmodule
