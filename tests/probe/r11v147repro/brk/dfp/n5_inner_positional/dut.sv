// § nestedDefaultPatLoc147
module top(output logic [2:0] o);
   logic [2:0] a [1:0] = '{default: '{1'b1, 1'b0, 1'b1}};
   assign o = a[1];
endmodule
