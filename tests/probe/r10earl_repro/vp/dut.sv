// vp.sv — pass 12, the BARE-IMPORTED RANGE-BOUND family (6 Earlgrey heads).
// § crossPkgRangeBoundFold (pass 2) substituted a declared-type range bound
// that names a package parameter WITH ITS QUALIFIER, with a module-LOCAL bound
// as the negative control.  That experiment never separated "bare" from
// "module-local": these six heads are all a BARE, wildcard-imported PACKAGE
// parameter in a bound.
//   hmac.sv:25          `input alert_rx_t [NumAlerts-1:0] alert_rx_i`
//   alert_handler.sv:33 `[NAlerts-1:0]`         golden constant ct9 sz32 dec1
//   flash_erase_ctrl:41 `[...-1:...]`           golden constant ct9 sz32 dec17
//   usbdev.sv:245       `for (i = 0; i < NEndpoints; i++)`  ct9 sz32 dec12
//     -> all four: golden a CONSTANT, ours a ref_obj
//   flash_ctrl.sv:310   `[MpRegions:0]`  we DO fold — at SIZE 64, golden 32
//   top_pkg.sv:8        (separate: a package's own localparam, top-flag head)
// Rows A/B/D/E are those shapes; row C is the qualified control the pass-2 law
// already handles and row F the module-LOCAL negative control it measured.
package vpp;
  parameter int NA = 4;
endpackage

module vpa import vpp::*; #(
  parameter int MW = 3
) (
  input  logic [NA-1:0]      a_i,   // A  bare, ARITHMETIC bound
  input  logic [NA:0]        b_i,   // B  bare, PLAIN bound
  input  logic [vpp::NA-1:0] c_i,   // C  QUALIFIED control (pass-2 law)
  input  logic [MW-1:0]      f_i,   // F  module-LOCAL control (must NOT fold)
  output logic               o
);
  logic [NA-1:0] w;                 // D  bare, net declaration
  int cnt;
  always_comb begin
    cnt = 0;
    for (int i = 0; i < NA; i++)    // E  bare, for-loop bound
      cnt = cnt + 1;
  end
  assign o = (|a_i) & (|b_i) & (|c_i) & (|f_i) & (|w) & (cnt != 0);
endmodule

module vptop;
  logic [3:0] a, c, w4;
  logic [4:0] b;
  logic [2:0] f;
  logic o;
  vpa u (.a_i(a), .b_i(b), .c_i(c), .f_i(f), .o(o));
endmodule
