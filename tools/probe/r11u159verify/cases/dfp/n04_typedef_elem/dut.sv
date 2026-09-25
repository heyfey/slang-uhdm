// § nestedDefaultPatLoc147
module top(output logic [1:0] o);
   typedef logic [1:0] e_t;
   e_t a [2][2] = '{default: '{default: 2'b01}};
   assign o = a[1][0];
endmodule
