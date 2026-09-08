// vF — a PACKAGE with a separated function export and a separated TASK export,
// plus a module that wildcard-imports the package (the hoisted copy).
package v216_pkg_f;
  export "DPI-C" function ef_fn;
  export "DPI-C" task ef_tk;
  function automatic int plain_f(int x);
    return x + 1;
  endfunction
  function automatic int ef_fn(int x);
    return x + 2;
  endfunction
  task automatic ef_tk(input int x);
  endtask
endpackage
module v216_top_f;
  import v216_pkg_f::*;
  initial begin
    if (plain_f(1) == 0) $display("x");
  end
endmodule
