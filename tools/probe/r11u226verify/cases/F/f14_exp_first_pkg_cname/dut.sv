// § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 — in a package: a function exported with a C name before its definition, formals of the package's own scalar typedef
package p;
  typedef int FILE_T;
  export "DPI-C" c_fn = function fn;
  function int fn(FILE_T f); return f; endfunction
endpackage
module top;
  import p::*;
endmodule
