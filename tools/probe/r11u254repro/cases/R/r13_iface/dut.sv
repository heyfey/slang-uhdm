// § procReplCountOwner254 (a replication count in an interface body process and continuous assignment)
package pk;
  parameter int N = 3;
endpackage
interface ifc;
  import pk::*;
  logic [5:0] q, r;
  always_comb begin : nb q = {N{2'b10}}; end
  assign r = {N{2'b01}};
endinterface
module top; ifc i(); endmodule
