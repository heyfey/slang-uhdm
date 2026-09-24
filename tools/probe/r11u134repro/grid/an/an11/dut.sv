// § memberAnonUnionAtKeyword134
package p;
   typedef struct packed {
      union packed {
         logic [3:0] B;
         logic [3:0] C;
      } U;
      logic D;
   } s_t;
endpackage
module top;
   p::s_t a;
   logic [3:0] o;
   assign o = a.U.B;
endmodule
