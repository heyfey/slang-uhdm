// § tfArgScalarTdWriter223
package p;
  typedef bit [3:0] NIB;
endpackage
module sub;
  import p::*;
  class mc;
    function void f(NIB x);
    endfunction
  endclass
  mc h;
endmodule
module top;
  sub u1();
  sub u2();
endmodule
