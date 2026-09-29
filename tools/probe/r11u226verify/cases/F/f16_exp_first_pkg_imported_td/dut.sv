// § tfArgScalarTdExportFirst223 § tfArgScalarTdWriter223 — in a package q importing p's scalar typedef: a function exported before its definition, and one after
package p;
  typedef int FILE_T;
endpackage
package q;
  import p::*;
  export "DPI-C" function fb;
  function int fb(FILE_T f); return f; endfunction
  function int fa(FILE_T f); return f; endfunction
  export "DPI-C" function fa;
endpackage
module top;
  import q::*;
endmodule
