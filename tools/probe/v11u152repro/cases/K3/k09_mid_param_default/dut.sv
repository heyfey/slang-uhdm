// § portConnParamFoldAtActual152
package pk;
  typedef struct packed { logic phase; } attr_t;
endpackage
module sel import pk::*; (input attr_t a_i [1], output logic x);
  assign x = a_i[0].phase;
endmodule
module mid import pk::*; #(parameter attr_t P[1] = '{'{phase: 1'b0}}) (output logic o);
  sel u(.a_i(P), .x(o));
endmodule
module top(output logic o);
  mid m(.o(o));
endmodule
