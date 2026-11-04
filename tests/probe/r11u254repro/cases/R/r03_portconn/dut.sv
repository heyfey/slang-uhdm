// § procReplCountOwner254 (a replication count in a port connection: definition and elaborated views)
package pk;
  parameter int N = 3;
endpackage
module sub (input logic [5:0] a);
endmodule
module top;
  import pk::*;
  logic [1:0] e;
  sub u (.a({N{e}}));
endmodule
