// § portConnParamFoldAtActual152
package pk;
  typedef struct packed { struct packed { logic q; } en; } cfg_t;
  typedef struct packed { cfg_t cfg; } attr_t;
  parameter attr_t Attr[1] = '{'{cfg: '{en: 1'b1}}};
endpackage
module sel import pk::*; (input attr_t a_i [1], output logic x);
  assign x = a_i[0].cfg;
endmodule
module top(output logic o);
  import pk::*;
  sel u(.a_i(Attr), .x(o));
endmodule
