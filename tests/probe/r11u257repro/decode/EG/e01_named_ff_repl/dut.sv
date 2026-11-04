// § stampFoldedPkgParamTs (decode only, ground A: Earlgrey_0_1 #193018, a package parameter folded as a replication count inside a named always_ff block: golden names the ref_typespec with the module, ours with the named block; ExprEmit)
package pk; parameter int N = 2; endpackage
module pinmux import pk::*; (input logic clk_i, input logic rst_ni, output logic [2*N-1:0] q);
  always_ff @(posedge clk_i or negedge rst_ni) begin : p_sleep
    if (!rst_ni) q <= {N{2'b10}};
    else q <= '0;
  end
endmodule
module top; logic c, r; logic [3:0] q; pinmux u(.clk_i(c), .rst_ni(r), .q(q)); endmodule
