// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class c;
    function void set(string id, UVM_FILE file);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
