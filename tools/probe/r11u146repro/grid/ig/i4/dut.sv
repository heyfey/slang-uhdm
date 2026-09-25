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
   if (PMPEnable) begin : g_pmp_registers
      pmp_cfg_t pmp_cfg2 [PMPNumRegions];
   end
endmodule
