// B3 — PACKAGE, export BELOW its definition, SEPARATED, plus an importer.
package v216_pkgb3;
  function automatic int eb_one(int x);
    return x + 1;
  endfunction
  function automatic int plain_b(int x);
    return x + 2;
  endfunction
  export "DPI-C" function eb_one;
  function automatic int plain_b2(int x);
    return x + 3;
  endfunction
endpackage
module v216_topb3;
  import v216_pkgb3::*;
  initial begin
    if (plain_b(1) == 0) $display("x");
  end
endmodule
