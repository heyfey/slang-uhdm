// § fnRetLitRhsSharesDefConst273
package pk;
  function automatic int f(); return 9; endfunction
endpackage
module dut (output int o [2]);
  assign o[0] = pk::f();
  import pk::*;
  assign o[1] = f();
endmodule
