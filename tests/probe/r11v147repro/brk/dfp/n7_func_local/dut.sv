// § nestedDefaultPatLoc147
module top(input logic [1:0] i, output logic [2:0] o);
   function automatic logic [2:0] f(input logic [1:0] k);
     logic [2:0] a [3:0];
     a = '{default: '{default: 1}};
     return a[k];
   endfunction
   assign o = f(i);
endmodule
