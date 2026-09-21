// r11u79 z6 — THE CONVERTING ARM.  Every other arm on this ground carries a
// module that IMPORTS the package, so its residue mixes the package listing
// with the module hoist.  This one does not: the module never imports `pz`,
// so the package's own listing is the whole difference and `uhdm-cmp` returns
// 0 exactly when LAWS A/B/C are all three right.
package pz;
  wire  [31:0] z_net;                                   // LAW A: a package NET
  wand  [7:0]  z_wand;                                  // LAW C: its net type
  supply0      z_sup0;
  logic [7:0]  z_uarr [0:1];                            // LAW A: array_var
  typedef struct packed { logic [7:0] x; logic [7:0] y; } zl_t;
  zl_t         z_sl;                                    // LAW C: no net type
  typedef struct packed { int x; logic [7:0] y; }         zi_t;
  zi_t         z_si;                                    // LAW B: struct_var
  typedef logic [3:0] zw_t;
  zw_t         z_td;                                    // LAW C: 36 elab only
  typedef enum logic [1:0] { ZA, ZB } ze_t;
  ze_t         z_en;
  logic [15:0] z_plain;
  int          z_int;
endpackage

module dut (output logic [31:0] o);
  assign o = 32'd0;
endmodule
