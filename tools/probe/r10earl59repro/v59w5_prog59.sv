// r10earl59 VERIFIER arm W5 — a PROGRAM body is a slang InstanceBody, so
// `symModuleLevel` is true inside one, but bindVariable has no uhdmprogram case.
program w5prog (input logic clk);
  logic [3:0] p_src;
  logic       p_e;
  wire  [3:0] p_net_d2;
  logic [3:0] p_var_d2;
  assign p_src = 4'h5;
  assign p_e   = 1'b0;
  if (1) begin : g_a
    if (1) begin : g_b
      wire [3:0] b_net;
      assign b_net    = p_src;
      assign p_net_d2 = p_e ? 4'b0 : b_net;
      assign p_var_d2 = p_e ? 4'b0 : b_net;
    end
  end
endprogram

module a1;
  wire clk;
  w5prog u_p (.clk(clk));
endmodule
