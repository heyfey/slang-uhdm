// v201 arm I — EXPLICIT import items, referenced and unreferenced, plus an
// explicit import of the REFERENT only.
package p201vi;
  parameter I_A = 13;
  parameter I_B = I_A;
  parameter I_C = I_A + 2;
endpackage
module m201vi;
  import p201vi::I_B;
  import p201vi::I_C;
endmodule
module m201vi2;
  import p201vi::I_A;
endmodule
