// § genLocalEnumConstShared184 (control): a compilation-unit enum read in a generate block, through a module variable and a block variable
typedef enum logic [1:0] {U0, U1, U2} u_e;
module dut #(parameter bit P = 1'b1) (input logic clk, output logic y, output logic z);
  u_e mq;
  if (P) begin : g
    u_e bq;
    always_ff @(posedge clk) begin
      mq <= U1;
      bq <= U2;
    end
    always_comb begin
      y = (mq == U0);
      z = (bq == U2);
    end
  end
endmodule
