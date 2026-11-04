// § procReplCountOwner254 (a qualified count, an operation count and a count beside an outside net)
package pk;
  parameter int N = 3;
endpackage
module top;
  import pk::*;
  logic [5:0] q;
  logic [7:0] r;
  logic [1:0] e;
  always_comb begin
    q = {pk::N{2'b10}};
    r = {N+1{e}};
    q = {N{e}} & q;
  end
endmodule
