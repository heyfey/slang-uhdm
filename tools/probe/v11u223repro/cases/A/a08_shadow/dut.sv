// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class c;
    typedef byte UVM_FILE;
    function void f(UVM_FILE x);
    endfunction
  endclass
  class d;
    function void g(UVM_FILE y);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
