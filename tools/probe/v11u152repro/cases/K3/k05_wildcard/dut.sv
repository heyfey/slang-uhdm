// § portConnParamFoldAtActual152
package pk;
  typedef struct packed { logic phase; } attr_t;
endpackage
module sel import pk::*; (input attr_t a_i [1], output logic x);
  assign x = a_i[0].phase;
endmodule
module top(output logic x);
  import pk::*;
  localparam attr_t a_i[1] = '{'{phase: 1'b1}};
  sel u(.*);
endmodule
