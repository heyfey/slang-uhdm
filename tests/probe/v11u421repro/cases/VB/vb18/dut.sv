// § bitsConcatLastResolvesAbstain421v
module top (input logic [3:0] a, output logic [7:0] o);
  typedef struct packed { logic [3:0] d; logic b; } s_t;
  s_t s;
  localparam W = $bits({s, a});
  localparam V = $bits({a});
  assign o = W + V;
endmodule
