// § procReplCountOwner254 (a package-qualified count without an import, a count in a generate instance's connection and in a parameter override)
package pk;
  parameter int N = 3;
  parameter int M = 2;
endpackage
module sub #(parameter logic [5:0] P = '0) (input logic [5:0] a, output logic [5:0] o);
  assign o = a ^ P;
endmodule
module top (input logic clk, output logic [5:0] o, output logic [5:0] p, output logic [5:0] q);
  always_ff @(posedge clk) begin : p_q
    o <= {pk::N{2'b10}};
  end
  import pk::*;
  for (genvar k = 0; k < 1; k++) begin : gk
    sub s (.a({N{2'b01}}), .o(p));
  end
  sub #(.P({N{2'b11}})) s2 (.a('0), .o(q));
endmodule
