// wh.sv — PASS 15: the § pkgTypespecInstanceIsTop `<null>` flavour.
// hmac / spi_device / tlul_adapter_sram / usbdev all read
//     failLhs package 'top_pkg' {top=1}  ^ design      failRhs <null>
// i.e. a typespec reachable from the module's DEF listing carries
// vpiInstance = the ELABORATED top_pkg in golden and NOTHING in ours.  None of
// those four names top_pkg: they reach it through tlul_pkg's `tl_h2d_t`, whose
// members are ranged by top_pkg's `TL_AW` / `TL_DW`.  This is that chain,
// three files deep, with a module that never mentions the ranging package.
package whq;
  localparam int W  = 32;
  localparam int DW = 32;
endpackage

package whp;
  typedef struct packed {
    logic [whq::W-1:0]  a;
    logic [whq::DW-1:0] d;
    logic [7:0]         u;
  } t_t;
  localparam int TW = whq::W + 8;
endpackage

module whnp (
  input  whp::t_t   tl_i,
  output whp::t_t   tl_o,
  output logic      o_o
);
  assign tl_o = tl_i;
  assign o_o  = ^tl_i.a;
endmodule

module whtop;
  whp::t_t ti, to;
  logic o;
  whnp u0(.tl_i(ti), .tl_o(to), .o_o(o));
endmodule
