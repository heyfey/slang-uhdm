// § procSelNameFinal282v
package pk; parameter int P = 4; endpackage
module top import pk::*; (input logic [7:0] a, output logic z [2]);
  struct packed { logic [1:0][7:0] f; } s;
  assign s.f = {a, a};
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb z[w] = s.f[w][P-1];
  end
endmodule
