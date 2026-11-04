// § typedefParentLastWriter134
package p;
   typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top(output logic [1:0] o);
   import p::*;
   e_t s;
   assign o = s;
endmodule
