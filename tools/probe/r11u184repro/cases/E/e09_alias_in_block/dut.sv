// § genLocalEnumConstShared184 (control): a module enum typedef aliased inside a generate block, read in the block's process
module dut #(parameter bit P = 1'b1) (input logic clk, output logic [1:0] y, output logic z);
  typedef enum logic [1:0] {C0, C1, C2} c_e;
  if (P) begin : ga
    typedef c_e d_e;
    d_e r;
    always_ff @(posedge clk) r <= (r == C0) ? C1 : C0;
    always_comb z = (y == C2);
    assign y = r;
  end
endmodule
