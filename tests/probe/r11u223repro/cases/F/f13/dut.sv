// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class c;
    function void set(p::UVM_FILE file, input p::UVM_FILE g);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
