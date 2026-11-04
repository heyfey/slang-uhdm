// § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 — in a module importing the package by a module-level wildcard: a function exported before its definition
package p;
  typedef int FILE_T;
endpackage
module top;
  import p::*;
  export "DPI-C" function fn;
  function int fn(FILE_T f); return f; endfunction
endmodule
