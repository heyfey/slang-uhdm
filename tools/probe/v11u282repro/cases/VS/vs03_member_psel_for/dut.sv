// § procSelNameFinal282v
package pk; parameter int P = 4; endpackage
module top import pk::*; (input logic [7:0] a, output logic [3:0] z [2]);
  struct packed { logic [7:0] f; } s;
  assign s.f = a;
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb z[w] = s.f[P-1:0];
  end
endmodule
