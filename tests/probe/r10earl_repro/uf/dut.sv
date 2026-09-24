// r10earl9 witness F — the REST of the bound-fold family, four positions the
// uc/ue witnesses did not reach:
//   rv_timer.sv:27:10  N_HARTS   local localparam SHADOWING a same-named
//                                member of a WILDCARD-IMPORTED package
//   usbdev.sv:140:10   NEndpoints  the same shape
//   alert_handler:33:22 NAlerts  a packed_array_typespec port bound
//                                (`alert_tx_t [NAlerts-1:0]`, a package
//                                 typedef as the element type)
//   hmac.sv:25:22      NumAlerts   the same shape
//   rv_plic.sv:41:36   NumTarget   an UNPACKED dim of a port
//                                (`output [SRCW-1:0] irq_id_o [NumTarget]`)
//   pinmux.sv:222:19   NDioPads    a genvar for-loop INIT expression
package ufp;
  parameter int NN = 1;      // the name a module also declares locally
  parameter int NA = 3;
  parameter int NT = 2;
  parameter int ND = 4;
  typedef struct packed { logic a; logic b; } el_t;
endpackage

module uf
  import ufp::*;
(
  input  logic clk_i,
  // row A — a PACKED-ARRAY port bound whose element is a package TYPEDEF
  input  el_t [NA-1:0] a_i,
  // row B — the same with a plain logic element (control: uc row C, agreed)
  input  logic [NA-1:0] b_i,
  // row C — an UNPACKED dim of a port reading a package parameter
  output logic [1:0]   c_o [NT],
  output logic         o
);
  // row D — a module-local localparam that SHADOWS ufp::NN
  localparam int NN = 1;
  logic [NN-1:0]        d_v;
  // row E — a genvar loop INIT reading a package parameter
  logic [7:0]           e_v;
  for (genvar k = ND; k < 8; k++) begin : gen_e
    assign e_v[k] = 1'b0;
  end
  // row F — an UNPACKED dim of a variable reading a package parameter
  logic [1:0]           f_v [NT];

  assign c_o[0] = 2'b0;
  assign c_o[1] = 2'b0;
  assign o = clk_i ^ ^a_i ^ ^b_i ^ ^d_v ^ ^e_v ^ ^f_v[0];
endmodule
