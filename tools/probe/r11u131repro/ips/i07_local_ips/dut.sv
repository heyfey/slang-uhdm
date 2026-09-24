// § paramIdxPartSelWholeSpan131
module top #(parameter bit [15:0] D = 16'h1234) ();
 localparam int unsigned X = D[2*4+:4];
 logic [X:0] q;
endmodule
