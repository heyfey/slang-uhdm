// § genLocalEnumConstShared184: a generate block's enum read through a block localparam and directly in a process
module dut #(parameter bit P = 1'b1) (input logic clk, output logic [1:0] y);
  if (P) begin : g
    typedef enum logic [1:0] {B0, B1, B2} b_e;
    localparam b_e LP = B2;
    b_e q;
    always_ff @(posedge clk) q <= (q == B0) ? LP : B1;
    always_comb y = (q == LP) ? 2'd1 : 2'd0;
  end
endmodule
