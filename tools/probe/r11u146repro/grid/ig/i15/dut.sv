// § defNetTypedefEndWrite134
package ibex_pkg;
  typedef struct packed {
    logic          lock;
    logic          exec;
  } pmp_cfg_t;
endpackage
module top (i);
    input i;
    import ibex_pkg::*;
    pmp_cfg_t a [2];
endmodule
