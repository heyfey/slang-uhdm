// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
interface zif;
  import p::*;
  e_t v;
endinterface
module bmod(input logic [1:0] i, output logic [1:0] o);
  import p::e_t;
  e_t w;
  assign w = e_t'(i);
  assign o = w;
endmodule
module amod(input logic [1:0] i, output logic [1:0] o);
  import p::*;
  e_t w;
  assign w = e_t'(i);
  assign o = w;
endmodule
module top(input logic [1:0] i, output logic [1:0] o, output logic [1:0] o2);
  amod u(.i(i), .o(o));
  bmod u2(.i(i), .o(o2));
  zif z();
endmodule
