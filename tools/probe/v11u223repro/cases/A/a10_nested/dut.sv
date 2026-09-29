// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class outer;
    class inner;
      function void f(UVM_FILE x);
      endfunction
    endclass
    function void g(UVM_FILE y);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
