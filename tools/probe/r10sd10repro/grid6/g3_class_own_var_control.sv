// g3 — NEGATIVE CONTROL #1: a class's OWN variable whose initialiser is a
// reference.  Nothing is imported and nothing is copied, so this cell must be
// IDENTICAL before and after.  It is the control for the 27 census rows that
// already carry the class-owner spelling on our side.
package p3;
  int a3 = 1;
endpackage
package q3;
  class c3;
    int own3 = 7;
    int ref3 = own3;
  endclass
endpackage
module m3;
  q3::c3 h3;
endmodule
