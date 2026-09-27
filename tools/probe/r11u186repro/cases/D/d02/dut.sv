// § enumConstUnderscoreDropped186 (a package enum: sized, based, and bare values)
package p;
typedef enum logic [15:0] { X = 16'd1_2, Y = 'h1_F, Z = 3_3 } e_t;
endpackage
module top(output logic [15:0] o);
  import p::*;
  e_t v;
  assign o = v;
endmodule
