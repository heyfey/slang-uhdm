// § memberAnonUnionAtKeyword134
module top;
   typedef struct {
      union {
         logic [1:0] B;
         int C;
      } U;
      logic D;
   } s_t;
   s_t a;
   initial a.U.C = 1;
endmodule
