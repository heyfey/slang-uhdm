// § procReplCountOwner254 (a replication count folded from an imported parameter in a named begin of an always_ff)
package pk;
  parameter int N = 3;
endpackage
module top import pk::*; (input logic clk, input logic rst_ni);
  logic [5:0] q;
  always_ff @(posedge clk or negedge rst_ni) begin : p_sleep
    if (!rst_ni) begin
      q <= '0;
    end else begin
      q <= {N{2'b10}};
    end
  end
endmodule
