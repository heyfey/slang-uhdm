// § paramIdxPartSelWholeSpan131
module top(output logic o);
 parameter bit [15:0] D = 16'h1234;
 if (D[1*4+:4] == 3) begin : g
   assign o = 1'b1;
 end else begin : h
   assign o = 1'b0;
 end
endmodule
