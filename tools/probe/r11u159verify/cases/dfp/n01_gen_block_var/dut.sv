// § nestedDefaultPatLoc147
module top(output logic [2:0] o);
   if (1) begin : g
     logic [2:0] a [3:0] = '{default: '{default: 0}};
     assign o = a[3];
   end
endmodule
