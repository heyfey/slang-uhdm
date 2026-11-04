// C3: the nested parameter imported and read, never connected to a port
// (the param_assign flavour alone).
package pk;
  typedef struct packed { struct packed { logic q; } en; } cfg_t;
  typedef struct packed { cfg_t cfg; } attr_t;
  parameter attr_t Attr[1] = '{'{cfg: '{en: 1'b1}}};
endpackage
module top(output logic o);
  import pk::*;
  assign o = Attr[0].cfg.en.q;
endmodule
