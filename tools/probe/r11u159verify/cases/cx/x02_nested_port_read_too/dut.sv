// § portConnParamFoldAtActual152 § nestedPatOpTsNoParent151
package pk;
  typedef struct packed { struct packed { logic q; } en; } cfg_t;
  typedef struct packed { cfg_t cfg; } attr_t;
  parameter attr_t Attr[1] = '{'{cfg: '{en: 1'b1}}};
endpackage
module sel import pk::*; (input attr_t a_i [1], output logic x);
  assign x = a_i[0].cfg.en.q;
endmodule
module top(output logic o, p);
  import pk::*;
  sel u(.a_i(Attr), .x(o));
  assign p = Attr[0].cfg.en.q;
endmodule
