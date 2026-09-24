// § paramIdxPartSelWholeSpan131
module top();
 parameter bit [15:0] D = 16'h1234;
 for (genvar i = 0; i < 2; i++) begin : g
   localparam bit [3:0] L = D[i*4+:4];
 end
endmodule
