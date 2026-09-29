// § tfArgScalarTdExportFirst223
package p;
  typedef int UVM_FILE;
  export "DPI-C" c_f = function f;
  function void f(UVM_FILE x);
  endfunction
  export "DPI-C" task t;
  task t(UVM_FILE y);
  endtask
  function void g(UVM_FILE z);
  endfunction
endpackage
module top;
  import p::*;
  UVM_FILE f0;
endmodule
