// § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 — in a module: a task exported before its definition and a function exported after, $unit-imported scalar typedef formals
package p;
  typedef shortint S_T;
endpackage
import p::*;
module top;
  export "DPI-C" task tb;
  task tb(S_T s); endtask
  function int fa(S_T s); return s; endfunction
  export "DPI-C" function fa;
endmodule
