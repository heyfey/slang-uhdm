// v58 VERIFIER arm V7 — call-argument and event-control discriminators.
package v7_pkg;
  function automatic logic [63:0] pf(input logic [63:0] x); return x; endfunction
endpackage
module v7_earl58 (input logic clk, input logic rst, input logic en,
                  input logic [63:0] v, output logic [63:0] o);
  function automatic logic [63:0] gf(input logic [63:0] x); return x; endfunction
  if (1) begin : g1
    localparam int unsigned L = 6;
    if (1) begin : g2
      logic [63:0] r_qual, r_sys, r_bare, r_ev2, r_evor, r_imm, r_blkfn;
      always_comb r_qual  = v7_pkg::pf(v[L-2:0]);
      always_comb r_sys   = {59'b0, $countones(v[L-2:0])};
      always_comb r_bare  = gf(v[L-2:0]);
      always @(posedge clk or negedge rst) r_ev2 <= v[L-2:0];
      always @(v[L-2:0] or en) r_evor = v;
      always_comb begin
        assert (v[L-2:0] != 0);
        r_imm = v[L-2:0];
      end
      function automatic logic [63:0] lf(input logic [63:0] x);
        return x[L-2:0];
      endfunction
      always_comb r_blkfn = lf(v);
      assign o = r_qual ^ r_sys ^ r_bare ^ r_ev2 ^ r_evor ^ r_imm ^ r_blkfn;
    end
  end
endmodule
