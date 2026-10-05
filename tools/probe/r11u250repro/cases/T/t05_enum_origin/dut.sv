// § patFlatTernPickedLeafSpan250
package p;
  typedef enum integer {k_a, k_b, k_c} k_e;
  typedef struct packed { k_e kind; integer n; } s_t;
  localparam s_t dflt = '{kind : k_c, n : 4};
  localparam s_t ovr = '{kind : k_a, n : 99};
  localparam s_t cfg = '{kind: (ovr.n == 99) ? dflt.kind : ovr.kind,
                         n: (ovr.n == 99) ? dflt.n : ovr.n};
endpackage
module top import p::*; (output integer o);
  assign o = cfg.n + cfg.kind;
endmodule
