// § castStructInstCopy260 (the cast in the top module's always_comb, a pkg-qualified typedef)
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
endpackage
module top (input logic [7:0] w, output logic [3:0] o);
  p::t_t r;
  always_comb begin
    r = p::t_t'(w);
    o = r.b;
  end
endmodule
