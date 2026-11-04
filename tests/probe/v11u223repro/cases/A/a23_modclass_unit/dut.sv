// § tfArgScalarTdWriter223
package p;
  typedef byte UVM_FILE;
endpackage
import p::*;
class uc;
  function void f(UVM_FILE x);
  endfunction
endclass
module top;
  class mc;
    function void g(UVM_FILE y);
    endfunction
  endclass
  UVM_FILE g0;
endmodule
