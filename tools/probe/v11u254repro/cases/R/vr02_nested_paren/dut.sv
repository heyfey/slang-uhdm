// § procReplCountOwner254 (a nested replication, a replication inside a concatenation, a parenthesised count, a count of M beside N)
package pk;
  parameter int N = 3;
  parameter int M = 2;
endpackage
module top import pk::*; (input logic clk, output logic [5:0] o, output logic [7:0] p, output logic [5:0] q, output logic [3:0] r);
  always_ff @(posedge clk) begin : p_a
    o <= {N{ {M{1'b1}} }};
    p <= {2'b00, {N{2'b10}}};
    q <= {(N){2'b01}};
    r <= {M{2'b11}};
  end
endmodule
