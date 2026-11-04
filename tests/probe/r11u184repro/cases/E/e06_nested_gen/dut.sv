// § genLocalEnumConstShared184: an outer generate block's enum read in a nested generate block, and an else branch with its own enum
module dut #(parameter bit P = 1'b1, parameter bit Q = 1'b1) (input logic clk, output logic [1:0] y);
  if (P) begin : g
    typedef enum logic [1:0] {S0, S1, S2} st_e;
    st_e q;
    if (Q) begin : h
      always_ff @(posedge clk) q <= (q == S0) ? S1 : S2;
    end
    always_comb y = (q == S2) ? 2'd3 : 2'd0;
  end else begin : ge
    typedef enum logic [1:0] {T0, T1} tt_e;
    tt_e r;
    always_ff @(posedge clk) r <= (r == T0) ? T1 : T0;
    assign y = r;
  end
endmodule
