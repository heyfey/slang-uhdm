// § tfArgScalarTdWriter223
`define DECL_SET(T) function void set_``T(T v); endfunction
package p;
  typedef int UVM_FILE;
  class c;
    `DECL_SET(UVM_FILE)
    function void g(
      UVM_FILE
        f);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
