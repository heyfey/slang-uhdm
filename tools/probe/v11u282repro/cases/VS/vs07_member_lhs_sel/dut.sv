// § procSelNameFinal282v
package pk; parameter int P = 4; endpackage
module top import pk::*; (output logic [7:0] y [2]);
  typedef struct packed { logic [7:0] f; } s_t;
  s_t s [2];
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb begin s[w].f = '0; s[w].f[P-1] = 1'b1; end
    assign y[w] = s[w].f;
  end
endmodule
