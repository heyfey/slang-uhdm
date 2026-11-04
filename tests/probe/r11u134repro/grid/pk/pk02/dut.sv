// § typedefParentLastWriter134
package p;
   typedef struct packed {
      logic [7:0] x;
      logic y;
   } t;
endpackage
module a_mod(output logic [7:0] o);
   import p::*;
   t a;
   assign o = a.x;
endmodule
module z_mod(output logic [7:0] o);
   import p::*;
   t b;
   assign o = b.x;
endmodule
module top(output logic [7:0] o1, o2);
   z_mod z(.o(o1));
   a_mod a(.o(o2));
endmodule
