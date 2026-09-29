// § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 — in a module: a function exported before its definition with a C name, a task exported after, both with $unit scalar typedef formals
package p;
  typedef int     FILE_T;
  typedef shortint S_T;
endpackage
import p::*;
module top;
  export "DPI-C" c_fn = function fn;
  function int fn(FILE_T f, S_T s); return f + s; endfunction
  task tk(FILE_T f); endtask
  export "DPI-C" task tk;
endmodule
