// § tfArgScalarTdExportOwnTd226v § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 (a module function exported before its definition, the formal package-qualified)
package p;
  typedef int FILE_T;
endpackage
module top;
  export "DPI-C" function fn;
  function int fn(p::FILE_T f); return f; endfunction
endmodule
