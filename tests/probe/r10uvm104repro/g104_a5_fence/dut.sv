// r10uvm104 arm 5 — the u2r FENCE shapes: a stringification with NO paste at
// all (`STRINGIFY(x)` in uhdm2rtlil array_assign / typedef_param, and the
// `int_types` message strings).  These must stay byte-identical.
`define STRINGIFY(x) `"x`"
`define MSG `"typ doesn't have expected size width`"
package fence_pk;
  parameter string f_s = `STRINGIFY(some_name);
  parameter string f_m = `MSG;
endpackage
module fence_top;
  initial begin
    if (1) $display(`STRINGIFY(alpha_beta));
  end
endmodule
