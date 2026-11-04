// § paramIdxPartSelWholeSpan131
module sub #(parameter bit [15:0] D = 16'h1234, parameter int unsigned X = D[1*4+:4]) ();
endmodule
module top();
 sub #(.D(16'h5678)) u();
endmodule
