// § tfArgScalarTdExportOwnTd226v § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 (an imported typedef, the function exported AFTER its definition: the control)
package q;
  typedef int FILE_T;
endpackage
module top;
  import q::*;
  function int fn(FILE_T f); return f; endfunction
  export "DPI-C" function fn;
endmodule
