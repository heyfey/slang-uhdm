// § typedefParentLastWriter134
package p;
   typedef struct packed {
      logic [7:0] x;
      logic y;
   } t;
endpackage
module sub(output logic [7:0] o);
   import p::*;
   t a;
   assign o = a.x;
endmodule
module top(output logic [7:0] o);
   import p::*;
   t b;
   sub u(.o(o));
   assign b = '0;
endmodule
