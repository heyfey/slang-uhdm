// § procReplCountOwner254 (control: a replication count in a continuous assignment and a net declaration assignment)
package pk;
  parameter int N = 3;
endpackage
module top;
  import pk::*;
  logic [5:0] q;
  assign q = {N{2'b10}};
  wire [5:0] w = {N{2'b01}};
endmodule
