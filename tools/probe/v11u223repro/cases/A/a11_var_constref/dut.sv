// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class c;
    function void f(input var UVM_FILE x, const ref UVM_FILE y, ref UVM_FILE z [4]);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
