// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class c;
    `include "hdr.svh"
    `DECL_F(mf, UVM_FILE)
    function void g(`ifdef NOPE int `else UVM_FILE `endif y);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE g;
endmodule
