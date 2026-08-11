// r10uvm54repro/a2 — the CLASS VALUE PARAMETER's typespec: which KIND, and
// which SPAN?
//
// LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  Read with
//   gold.sh a2 <outdir> <bin>   then   clsparam.py <dump> rows
//
// Every cell name below is a PARAMETER name in this file.  The axis under test
// is "was a data type WRITTEN", and the two halves must move in opposite
// directions: the WRITTEN half takes that type's typespec spanning the TYPE
// SYNTAX, the IMPLICIT half keeps an int_typespec spanning the WHOLE
// DECLARATION.  The implicit half is the shape the live `ClassParamAsParam` and
// `ClassTypeParam` canaries carry, so a law that ignored it would break them.
//
// The `bcell`/`vcell` cells are DELIBERATELY LEFT ALONE by this pass: golden's
// answer for them is recorded here as a measurement, and the code falls through
// to the old shape rather than guessing a typespec kind no arm has measured.

package q54;
  // WRITTEN string / WRITTEN int / WRITTEN `int unsigned`
  class pstr54 #(string scell = "hello");
    int a;
  endclass
  class pint54 #(int icell = 7);
    int b;
  endclass
  class puns54 #(int unsigned ucell = 9);
    int c;
  endclass
  // IMPLICIT: no data type written at all — the control.
  class pimp54 #(pcell = 3);
    int d;
  endclass
  // IMPLICIT with a SIZED literal RHS: the packed-range cell.
  class psz54 #(zcell = 8'hAA);
    int e;
  endclass
  // WRITTEN byte / WRITTEN packed vector: measured, NOT taken by this pass.
  class pbyt54 #(byte bcell = 5);
    int f;
  endclass
  class pvec54 #(bit [7:0] vcell = 8'h0F);
    int g;
  endclass
  // TWO declarators on ONE parameter line, WRITTEN type: does each declarator
  // get its own object, and does each carry the SAME type-syntax span?
  class ptwo54 #(int t1cell = 1, t2cell = 2);
    int h;
  endclass
endpackage

module a2_top54;
  q54::pstr54 #("hi")   s0_54;
  q54::pint54 #(3)      i0_54;
  q54::puns54 #(4)      u0_54;
  q54::pimp54 #(5)      m0_54;
  q54::psz54  #(8'h11)  z0_54;
  q54::pbyt54 #(6)      b0_54;
  q54::pvec54 #(8'h22)  v0_54;
  q54::ptwo54 #(7, 8)   w0_54;
  initial begin
    s0_54 = new;
    i0_54 = new;
    u0_54 = new;
    m0_54 = new;
    z0_54 = new;
    b0_54 = new;
    v0_54 = new;
    w0_54 = new;
  end
endmodule
