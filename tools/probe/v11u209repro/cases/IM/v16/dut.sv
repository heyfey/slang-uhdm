// § portConnOpLeafChain209: an interface instance port connected with an operation over a struct member
package p;
  typedef struct packed { logic [3:0] d; logic v; } req_t;
endpackage
interface cif (input logic clk);
  logic [3:0] q;
endinterface
module top (input p::req_t r, input logic t, output logic [3:0] o);
  p::req_t s;
  assign s = r;
  cif c (.clk(s.v & t));
  assign c.q = s.d;
  assign o = c.q;
endmodule
