// § defNetTypedefEndWrite134
package ibex_pkg;
  typedef struct packed {
    logic          lock;
    logic          exec;
  } pmp_cfg_t;
endpackage
module top;
    import ibex_pkg::*;
    localparam int N = 2;
    pmp_cfg_t pmp_cfg1 [N];
endmodule
