// § tfArgScalarTdExportOwnTd226v § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 (a typedef of the own typedef, the function exported before its definition)
package p;
  typedef int FILE_T;
  typedef FILE_T F2_T;
  export "DPI-C" function fn;
  function int fn(F2_T f, FILE_T g); return f + g; endfunction
endpackage
module top;
  import p::*;
endmodule
