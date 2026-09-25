// § defNetTypedefEndWrite134
package ibex_pkg;
  typedef struct packed {
    logic          lock;
    logic          exec;
  } pmp_cfg_t;
endpackage
module top;
    import ibex_pkg::*;
    pmp_cfg_t pmp_cfg1 [2];
    logic o;
    assign o = pmp_cfg1[0].lock;
endmodule
