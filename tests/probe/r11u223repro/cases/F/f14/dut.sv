// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class c;
    function void set(UVM_FILE files[], ref UVM_FILE q[$]);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
