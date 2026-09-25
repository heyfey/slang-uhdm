// § portConnParamFoldAtActual152
package pk;
  typedef struct packed { logic phase; logic [1:0] mode; } attr_t;
  parameter attr_t Attr[1] = '{'{phase: 1'b1, mode: 2'd2}};
endpackage
module sel import pk::*; (input attr_t a_i [1], output logic x);
  assign x = a_i[0].phase;
endmodule
module top(output logic o);
  import pk::*;
  sel u(Attr, o);
endmodule
