// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class c;
    extern function void set(string id, UVM_FILE file);
  endclass
  function void c::set(string id, UVM_FILE file);
  endfunction
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
