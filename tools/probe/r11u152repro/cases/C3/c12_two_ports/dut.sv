// § portConnParamFoldAtActual152
package pk;
  typedef struct packed { logic phase; } attr_t;
  parameter attr_t Attr[1] = '{'{phase: 1'b1}};
  parameter attr_t Brr[1] = '{'{phase: 1'b0}};
endpackage
module sel import pk::*; (input attr_t a_i [1], input attr_t b_i [1], output logic x);
  assign x = a_i[0].phase ^ b_i[0].phase;
endmodule
module top(output logic o);
  import pk::*;
  sel u(.a_i(Attr), .b_i(Brr), .x(o));
endmodule
