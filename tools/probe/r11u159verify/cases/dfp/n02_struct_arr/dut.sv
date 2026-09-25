// § nestedDefaultPatLoc147
module top(output logic [1:0] o);
   typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
   s_t arr [2] = '{default: '{default: 0}};
   assign o = arr[1].a;
endmodule
