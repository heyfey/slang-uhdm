// § tfArgScalarTdWriter223
package p;
  typedef shortint UVM_FILE;
  class c;
    function void f(UVM_FILE x [2], UVM_FILE y [1:0][3], UVM_FILE z [string]);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE g;
endmodule
