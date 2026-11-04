// § tfArgScalarTdExportOwnTd226v § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 (an interface's own typedef, the function exported before its definition)
interface ifc;
  typedef int FILE_T;
  export "DPI-C" function fn;
  function int fn(FILE_T f); return f; endfunction
endinterface
module top;
  ifc u();
endmodule
