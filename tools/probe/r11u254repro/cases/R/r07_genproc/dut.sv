// § procReplCountOwner254 (a replication count in a process inside if and for generate blocks, one and two levels down)
package pk;
  parameter int N = 3;
endpackage
module top #(parameter int P = 1);
  import pk::*;
  logic [5:0] q, r, s;
  if (P == 1) begin : g_if
    always_comb q = {N{2'b10}};
    for (genvar k = 0; k < 1; k++) begin : g_for
      always_comb r = {N{2'b01}};
    end
  end
  for (genvar j = 0; j < 1; j++) begin : g_f2
    always_comb s = {N{2'b11}};
  end
endmodule
