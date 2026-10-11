// § procSelNameFinal282v
package pk; parameter int P = 4; endpackage
module top import pk::*; (input logic [7:0] a, output logic z [2][2]);
  struct packed { logic [7:0] f; } s;
  assign s.f = a;
  for (genvar x = 0; x < 2; x++) begin : gx
    for (genvar y = 0; y < 2; y++) begin : gy
      always_comb z[x][y] = s.f[P-1];
    end
  end
endmodule
