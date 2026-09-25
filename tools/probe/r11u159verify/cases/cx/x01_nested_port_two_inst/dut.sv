// § portConnParamFoldAtActual152 § nestedPatOpTsNoParent151
package pk;
  typedef struct packed { struct packed { logic q; } en; } cfg_t;
  typedef struct packed { cfg_t cfg; logic r; } attr_t;
  parameter attr_t Attr[1] = '{'{cfg: '{en: 1'b1}, r: 1'b0}};
endpackage
module sel import pk::*; (input attr_t a_i [1], output logic x);
  assign x = a_i[0].cfg.en.q ^ a_i[0].r;
endmodule
module top(output logic o1, o2);
  import pk::*;
  sel u1(.a_i(Attr), .x(o1));
  sel u2(.a_i(Attr), .x(o2));
endmodule
