// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  typedef int UVM_FILE2;
  function automatic UVM_FILE get(UVM_FILE2 x = 1);
    UVM_FILE loc;
    return x;
  endfunction
  task automatic t(UVM_FILE a, UVM_FILE b);
  endtask
endpackage
module top;
  import p::*;
  UVM_FILE f;
  initial f = get(2);
endmodule
