// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class c;
    function void set(UVM_FILE file);
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class d extends c;
    function void put(UVM_FILE file);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  d h;
endmodule
