// § procSelNameFinal282v
package pk; parameter int P = 4; endpackage
module top import pk::*; (input logic [7:0] a, output logic z);
  struct packed { logic [7:0] f; } s;
  assign s.f = a;
  if (1) begin : g
    always_comb z = s.f[P-1];
  end
endmodule
