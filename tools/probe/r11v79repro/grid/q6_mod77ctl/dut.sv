// v11u79 q6 — THE PASS-77 CONTROL.  The MODULE's hoisted copy of an imported
// package listing is § caImportedPkgNetHoist77's ground, NOT r11u79's.  Every
// shape r11u79 adds to the package listing is spelled here so the module-side
// hoist can be scored for an unwanted change: the two halves must not move
// together.
package p6;
  wire [7:0]  h_net;
  logic [7:0] h_uarr [0:1];
  typedef struct packed { int x; logic [7:0] y; } hsi_t;
  hsi_t       h_struct;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } hsl_t;
  hsl_t       h_sl;
  union packed { logic [7:0] a; logic [7:0] b; } h_anonu;
  logic [7:0] h_var;
  typedef logic [7:0] hw_t;
  wire hw_t   h_wtd;
  hsi_t       h_uasi [0:1];
endpackage

module dut (output logic [31:0] o);
  import p6::*;
  assign o = {24'd0, h_net} ^ {24'd0, h_uarr[0]} ^ {16'd0, h_struct}
           ^ {16'd0, h_sl} ^ {24'd0, h_anonu} ^ {24'd0, h_var}
           ^ {24'd0, h_wtd} ^ {16'd0, h_uasi[0]};
endmodule
