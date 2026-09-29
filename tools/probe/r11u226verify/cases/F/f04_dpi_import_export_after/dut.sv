// § tfArgScalarTdWriter223 § tfArgScalarTdExportFirst223 — DPI imports with typedef formals (not recorded), a package function exported after its definition and a task exported before it
package p;
  typedef int     FILE_T;
  typedef longint L_T;
  import "DPI-C" function int c_open(FILE_T f, L_T l);
  export "DPI-C" task t_before;
  task automatic t_before(FILE_T f, output L_T l); l = f; endtask
  function automatic int f_after(FILE_T f); return f + 1; endfunction
  export "DPI-C" function f_after;
endpackage
module top;
  import p::*;
endmodule
