// § typedefParentLastWriter134
package p;
   typedef union packed {
      logic [7:0] b;
      logic [7:0] c;
   } u_t;
endpackage
module top(output logic [7:0] o);
   import p::*;
   u_t m;
   assign o = m.b;
endmodule
