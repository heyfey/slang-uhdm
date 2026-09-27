// § genLocalEnumConstShared184 (control): a MODULE enum and variable, read in a generate block's process
module dut #(parameter bit P = 1'b1) (input logic clk, output logic [1:0] y);
  typedef enum logic [1:0] {S0, S1, S2} st_e;
  st_e q;
  if (P) begin : g
    always_ff @(posedge clk) begin
      if (q == S0) q <= S1; else q <= S0;
      y <= (q == S2) ? 2'd1 : 2'd0;
    end
  end
endmodule
