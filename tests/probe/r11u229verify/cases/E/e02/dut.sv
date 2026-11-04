// § tfArgScalarTdExportOwnTd226v § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 (a module's own typedef, the function exported before its definition)
module top;
  typedef int FILE_T;
  export "DPI-C" function fn;
  function int fn(FILE_T f); return f; endfunction
endmodule
