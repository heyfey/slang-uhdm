// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
program zprog;
  import p::*;
  e_t v;
endprogram
module amod(input logic [1:0] i, output logic [1:0] o);
  import p::*;
  e_t w;
  assign w = e_t'(i);
  assign o = w;
endmodule
module top(input logic [1:0] i, output logic [1:0] o);
  amod u(.i(i), .o(o));
  zprog pr();
endmodule
