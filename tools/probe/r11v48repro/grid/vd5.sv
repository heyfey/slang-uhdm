// vd5 — the SAME signed localparam sizing a packed dim in the MODULE body, in a
// PORT, and in a gen-block, all at once (three emission views).
module vd5 #(parameter int unsigned W = 4) (
    input  logic [VDPS:0] p_in,
    output logic          o
);
  localparam int VDPS = 4;
  logic [VDPS:0] body;
  generate
    if (W > 0) begin : gb
      logic [VDPS:0] gv;
      assign gv = '0;
    end
  endgenerate
  assign o = p_in[0] ^ body[0] ^ gb.gv[0];
endmodule
