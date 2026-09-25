// § defNetTypedefEndWrite134
package ibex_pkg;
  typedef struct packed {
    logic          lock;
    logic          exec;
  } pmp_cfg_t;
endpackage
module top#(parameter bit PMPEnable = 1) ();
    localparam int PMPNumRegions = 2;
    import ibex_pkg::*;
    pmp_cfg_t pmp_cfg1 [PMPNumRegions];
endmodule
