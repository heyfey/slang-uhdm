// § nestedPatOpTsNoParent151
module top(output logic o);
  typedef struct packed { struct packed { logic q; } en; } cfg_t;
  typedef struct packed { cfg_t cfg; } attr_t;
  parameter attr_t Attr[1] = '{'{cfg: '{en: 1'b1}}};
  assign o = Attr[0].cfg.en.q;
endmodule
