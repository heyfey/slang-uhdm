// v58 VERIFIER arm V6 — the OTHER § genProcParamFold no-fold regions asked of a
// d1 GEN-SCOPE parameter: for-stmt header positions, function-CALL arguments, a
// variable select index, a concurrent assertion, a nested gen block, and an
// event-control expression.
module v6_earl58 (input logic clk, input logic en, input logic [63:0] v,
                  output logic [63:0] o);
  function automatic logic [63:0] gf(input logic [63:0] x); return x; endfunction
  if (1) begin : g1
    localparam int unsigned L = 6;
    if (1) begin : g2
      logic [63:0] r_hdrinit, r_hdrcond, r_hdrinc, r_call, r_vsel, r_ev, r_sys;
      logic [63:0] arr [0:7];
      integer k2;
      always @(posedge clk) for (int k = v[L-2:0]; k < 2; k++) r_hdrinit <= 1;
      always @(posedge clk) for (k2 = 0; k2 < v[L-2:0]; k2++) r_hdrcond <= 1;
      always @(posedge clk) for (k2 = 0; k2 < 2; k2 = k2 + v[L-2:0]) r_hdrinc <= 1;
      always_comb r_call = gf(v[L-2:0]);
      always_comb r_vsel = arr[v[L-2:0]];
      always @(v[L-2:0]) r_ev = v;
      always_comb r_sys = {59'b0, $countones(v[L-2:0])};
      assign o = r_hdrinit ^ r_hdrcond ^ r_hdrinc ^ r_call ^ r_vsel ^ r_ev ^ r_sys;
    end
  end
endmodule
