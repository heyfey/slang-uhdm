// § tfArgScalarTdExportOwnTd226v § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 (a program's own typedef, the function exported before its definition)
program prg;
  typedef int FILE_T;
  export "DPI-C" function fn;
  function int fn(FILE_T f); return f; endfunction
endprogram
module top;
endmodule
