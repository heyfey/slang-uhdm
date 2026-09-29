// § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 — in a module: a function exported (no C name) before its definition, formals of a $unit-imported scalar typedef
package p;
  typedef int FILE_T;
endpackage
import p::*;
module top;
  export "DPI-C" function fn;
  function int fn(FILE_T f); return f; endfunction
endmodule
