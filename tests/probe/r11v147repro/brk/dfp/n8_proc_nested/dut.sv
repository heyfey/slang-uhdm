// § nestedDefaultPatLoc147
module top(input logic c, output logic [2:0] o);
   logic [2:0] a [3:0];
   always_comb begin
     a = '{default: '{default: c}};
     o = a[1];
   end
endmodule
