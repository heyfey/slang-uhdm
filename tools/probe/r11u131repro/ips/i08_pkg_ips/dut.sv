// § paramIdxPartSelWholeSpan131
package pk;
 parameter bit [15:0] D = 16'h1234;
 parameter int unsigned X = D[1*4+:4];
endpackage
module top();
 logic [pk::X:0] q;
endmodule
