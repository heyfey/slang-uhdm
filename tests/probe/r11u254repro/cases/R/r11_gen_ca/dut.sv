// § procReplCountOwner254 (generate scopes: for-generate continuous assignments with a whole target and a select target, an if-generate, two levels down)
package pk;
  parameter int N = 3;
endpackage
module top #(parameter int P = 1);
  import pk::*;
  logic [5:0] q;
  logic [5:0] m [2];
  for (genvar k = 0; k < 2; k++) begin : g_for
    assign m[k] = {N{2'b10}};
    if (P == 1) begin : g_in
      logic [5:0] w;
      assign w = {N{2'b01}};
    end
  end
  if (P == 1) begin : g_if
    assign q = {N{2'b11}};
  end
endmodule
