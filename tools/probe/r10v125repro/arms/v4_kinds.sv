// v125 arm V4 — CALL KINDS carrying a converting output actual.
package Kind_Pkg;
  typedef logic [63:0] W64;
  import "DPI-C" function int dpiGrab(output W64 v);
  import "DPI-C" task dpiTask(output W64 v);
  function automatic int pkgGrab(output W64 v); v = 64'd9; return 0; endfunction
  task automatic pkgTask(output W64 v); v = 64'd8; endtask
endpackage

module Kind_Top;
  import Kind_Pkg::*;
  logic [31:0] shortVar;
  logic [63:0] longVar;
  string       txt;
  int          got;
  int          plusVal;
  real         rr;

  class Kind_Meth;
    function automatic int meth(output W64 v); v = 64'd7; return 0; endfunction
    task automatic methT(output W64 v); v = 64'd6; endtask
  endclass
  Kind_Meth km;

  task automatic modTask(output W64 v); v = 64'd5; endtask
  function automatic int modFunc(output W64 v); v = 64'd4; return 0; endfunction

  initial begin
    got = dpiGrab(shortVar);
    dpiTask(shortVar);
    got = pkgGrab(shortVar);
    pkgTask(shortVar);
    got = km.meth(shortVar);
    km.methT(shortVar);
    modTask(shortVar);
    got = modFunc(shortVar);
    got = pkgGrab(longVar);            // matching control
    void'($value$plusargs("N=%d", plusVal));
    got = $sscanf(txt, "%d", plusVal);
    $cast(got, plusVal);
    void'($fscanf(0, "%f", rr));
  end
endmodule
