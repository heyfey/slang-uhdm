// § portConnParamFoldAtActual152
package pk;
  typedef struct packed { logic phase; } attr_t;
endpackage
module sel import pk::*; (input attr_t a_i [1], output logic x);
  assign x = a_i[0].phase;
endmodule
module top(output logic o);
  import pk::*;
  localparam attr_t Attr[1] = '{'{phase: 1'b1}};
  sel u(.a_i(Attr), .x(o));
endmodule
