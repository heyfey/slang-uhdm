// § genLocalEnumConstShared184: two sibling generate blocks each declaring an enum type of the same name and constants
module dut #(parameter bit P = 1'b1) (input logic clk, output logic [1:0] y, output logic [1:0] z);
  if (P) begin : ga
    typedef enum logic [1:0] {A0, A1} a_e;
    a_e q;
    always_ff @(posedge clk) q <= (q == A0) ? A1 : A0;
    always_comb y = (q == A1) ? 2'd1 : 2'd0;
  end
  if (P) begin : gb
    typedef enum logic [1:0] {B0 = 2'd2, B1} a_e;
    a_e q;
    always_ff @(posedge clk) q <= (q == B0) ? B1 : B0;
    always_comb z = (q == B1) ? 2'd3 : 2'd0;
  end
endmodule
