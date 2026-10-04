// § namedCallArgFormalTs236 — named calls with parameter and literal actuals, an enum formal, and a call used as an index
package p;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  typedef logic [7:0] byte_t;
endpackage
module top import p::*; #(parameter int P = 3) (input logic [7:0] a, input e_t e, output int o, output logic o2);
  function automatic int h(e_t x, byte_t y);
    return int'(x) + y;
  endfunction
  assign o = h(.y(P), .x(e)) + h(.x(E1), .y(8'd4));
  assign o2 = a[h(.x(e), .y(a)) % 8];
endmodule
