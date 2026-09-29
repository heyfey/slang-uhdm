// § tfArgScalarTdWriter223
package p;
  typedef bit [3:0] NIB;
  class c;
    function void f(NIB a,
                    NIB b);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  NIB g;
endmodule
