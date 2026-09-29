// § tfArgScalarTdExportOwnTd226v § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 (the export before the DPI import, an imported typedef, in a package)
package q;
  typedef int FILE_T;
endpackage
package p;
  import q::*;
  export "DPI-C" function fn;
  import "DPI-C" function int c_fn(FILE_T f);
  function int fn(FILE_T f); return c_fn(f); endfunction
endpackage
module top;
  import p::*;
endmodule
