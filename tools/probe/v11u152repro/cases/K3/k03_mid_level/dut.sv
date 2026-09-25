// § portConnParamFoldAtActual152
package pk;
  typedef struct packed { logic phase; logic [1:0] w; } attr_t;
  parameter attr_t Attr[2] = '{'{phase: 1'b1, w: 2'd2}, '{phase: 1'b0, w: 2'd1}};
endpackage
module sel import pk::*; (input attr_t a_i [2], output logic x);
  assign x = a_i[1].phase;
endmodule
module mid(output logic o);
  import pk::*;
  sel s0(.a_i(Attr), .x(o));
endmodule
module top(output logic o);
  mid m(.o(o));
endmodule
