// r11u77 y6 — THE CONVERTING WITNESS.  Every other arm on this ground is
// MASKED at the package object itself, because our PACKAGE listing lists
// neither a package NET nor an unpacked-array package variable and stamps the
// same over-broad net type on a struct/union/typedef-chain entry (the
// `emitPackage` road, R0 below).  This arm uses ONLY the package shapes whose
// package rows ALREADY agree golden-for-golden, so the module hoist is the
// whole remaining difference and the arm can be read end to end:
//   * `reg`      the def-view hoisted net moves 36 -> 48
//   * `integer`  36 -> none        * `time` 36 -> none
// A packed STRUCT cannot ride this arm: its own PACKAGE row carries the same
// over-broad net type one file over (`py::y_struct` 36 where golden writes
// none, the `uhdmtopPackages` road), which is R0 below.  The struct holder's
// move to `struct_net` and its namesake cell are witnessed on `y2`/`y4`/`xe`
// instead, where the package mask is already there.
package py;
  logic  [15:0]    y_logic;
  reg    [15:0]    y_reg;
  integer          y_integer;
  time             y_time;
  bit    [15:0]    y_bit;
  typedef logic [3:0] yw_t;
  yw_t             y_tdlogic;
  typedef logic [1:0][7:0] yp_t;
  yp_t             y_tdparr;
  typedef enum logic [1:0] { YA, YB } ye_t;
  ye_t             y_tdenum;
endpackage

module dut (output logic [31:0] o);
  import py::*;
  for (genvar i = 0; i < 1; i = i + 1) begin : gy
    logic [31:0] y_tdenum;  assign y_tdenum  = 32'd2;
    logic [31:0] y_reg;     assign y_reg     = 32'd3;
    logic [31:0] y_time;    assign y_time    = 32'd4;
  end
  assign o = gy[0].y_tdenum ^ gy[0].y_reg ^ gy[0].y_time;
endmodule
