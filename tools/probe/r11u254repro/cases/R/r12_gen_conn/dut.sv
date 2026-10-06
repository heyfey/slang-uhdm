// § procReplCountOwner254 (a replication count in a port connection inside a generate block and a selected target port)
package pk;
  parameter int N = 3;
endpackage
module sub (input logic [5:0] a);
endmodule
module top #(parameter int P = 1);
  import pk::*;
  logic [1:0] e;
  logic [5:0] f;
  if (P == 1) begin : g_if
    sub u (.a({N{e}}));
  end
  sub v (.a(f[{N{1'b0}}+:2] ));
endmodule
