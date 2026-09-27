// § genLocalEnumConstShared184: a generate block's variable typed by an inline enum
module dut #(parameter bit P = 1'b1) (input logic clk, output logic y);
  if (P) begin : g
    enum logic [1:0] {X0, X1, X2} st;
    always_ff @(posedge clk) st <= (st == X0) ? X1 : X2;
    always_comb y = (st == X2);
  end
endmodule
