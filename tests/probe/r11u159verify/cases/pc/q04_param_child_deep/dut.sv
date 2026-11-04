// § portConnParamFoldAtActual152
package pk;
  typedef struct packed { logic phase; } attr_t;
  parameter attr_t Attr[1] = '{'{phase: 1'b1}};
endpackage
module sel import pk::*; #(parameter int N = 1) (input attr_t a_i [N], output logic x);
  assign x = a_i[0].phase;
endmodule
module mid(output logic o);
  import pk::*;
  sel #(.N(1)) u(.a_i(Attr), .x(o));
endmodule
module top(output logic o);
  mid m(.o(o));
endmodule
