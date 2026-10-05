// § patFlatTernPickedLeafSpan250
package p;
  typedef enum logic [1:0] {e_x, e_y, e_z} e_t;
  typedef struct packed { integer f; integer g; integer h; } s_t;
  localparam s_t dflt = '{f : (1 << e_y) | (1 << e_z)
                         ,g : -3
                         ,h : (1 << e_x)};
  localparam s_t ovr = '{default : "inv"};
  localparam s_t cfg = '{f: (ovr.f == "inv") ? dflt.f : ovr.f,
                         g: (ovr.g == "inv") ? dflt.g : ovr.g,
                         h: (ovr.h == "inv") ? dflt.h : ovr.h};
endpackage
module top import p::*; (output integer o);
  assign o = cfg.f + cfg.g + cfg.h;
endmodule
