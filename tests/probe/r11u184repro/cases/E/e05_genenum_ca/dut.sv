// § genLocalEnumConstShared184: a generate-block enum read in the block's continuous assignments and a function
module dut #(parameter bit P = 1'b1) (input logic clk, output logic y, output logic z, output logic [1:0] w);
  if (P) begin : g
    typedef enum logic [1:0] {S0, S1, S2} st_e;
    st_e q;
    assign y = q == S1;
    assign w = q[S1];
    assign z = (q != S2) ? 1'b1 : 1'b0;
    always_ff @(posedge clk) q <= (q == S0) ? S1 : S0;
  end
endmodule
