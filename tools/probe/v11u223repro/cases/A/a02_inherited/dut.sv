// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class c;
    function void set(UVM_FILE a, b, input int k, UVM_FILE d);
    endfunction
    task t(output UVM_FILE o1, o2);
    endtask
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
