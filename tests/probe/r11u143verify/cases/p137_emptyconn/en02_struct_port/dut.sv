// § emptyNamedConnLowConnAtDecl137
// case en02: an explicitly empty named connection of a packed-struct output port
package sp; typedef struct packed { logic v; logic [2:0] d; } s_t; endpackage
module sub(input logic a, output sp::s_t s, output logic c);
  assign s = {a, 3'b101};
  assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .s(), .c(y));
endmodule
