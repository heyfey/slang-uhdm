// § tfArgScalarTdExportOwnTd226v § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 (a DPI import using the own typedef, then the export, then the definition)
package p;
  typedef int FILE_T;
  import "DPI-C" function int c_fn(FILE_T f);
  export "DPI-C" function fn;
  function int fn(FILE_T f); return c_fn(f); endfunction
endpackage
module top;
  import p::*;
endmodule
