// § pasteChainRunning160v
`define SIG(n) \
  s_``n[1] = 1'b1; \
s_``n[0] = 1'b0;
module top (output logic [1:0] o);
  logic [1:0] s_q;
  always_comb begin
    `SIG(q)
  end
  assign o = s_q;
endmodule
