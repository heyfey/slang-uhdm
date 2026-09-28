// § portConnOpLeafChain209 — r11u217 m06: a connection operation reading a LOCAL struct variable member and a struct PORT member (no interface), in a module instantiated twice
package q;
  typedef struct packed { logic [3:0] d; logic e; } r_t;
endpackage
module inner (input logic b, output logic o);
  assign o = b;
endmodule
module wrapper (input q::r_t r, output logic o, output logic x);
  q::r_t loc;
  assign loc = r;
  inner u (.b(loc.e | r.d[0]), .o(o));
  inner v (.b(loc.d[1] ^ loc.e), .o(x));
endmodule
module top (input q::r_t r, output logic [1:0] o, output logic [1:0] x);
  wrapper w0 (.r(r), .o(o[0]), .x(x[0]));
  wrapper w1 (.r(~r), .o(o[1]), .x(x[1]));
endmodule
