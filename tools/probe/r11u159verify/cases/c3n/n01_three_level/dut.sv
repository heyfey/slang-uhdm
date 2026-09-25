// § nestedPatOpTsNoParent151
package pk;
  typedef struct packed { logic q; } l3_t;
  typedef struct packed { l3_t en; } l2_t;
  typedef struct packed { l2_t cfg; logic r; } attr_t;
  parameter attr_t Attr[1] = '{'{cfg: '{en: '{q: 1'b1}}, r: 1'b0}};
endpackage
module top(output logic o);
  import pk::*;
  assign o = Attr[0].cfg.en.q;
endmodule
