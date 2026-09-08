// L — the export item comes out of a MACRO EXPANSION buffer.
`define V216_EXP_ONE export "DPI-C" function el_one;
package v216_pkg_l;
  `V216_EXP_ONE
  function automatic int plain_l(int x);
    return x + 1;
  endfunction
  function automatic int el_one(int x);
    return x + 2;
  endfunction
endpackage
module v216_top_l;
  import v216_pkg_l::*;
  initial begin
    if (plain_l(1) == 0) $display("x");
  end
endmodule
