// § nestedDefaultPatLoc147
module top(output logic [2:0] o);
   logic [2:0] a [3:0] = '{0: '{default: 1}, default: '{default: 0}};
   assign o = a[3];
endmodule
