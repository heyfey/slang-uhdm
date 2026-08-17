// r10uvm87 arm 3 — how a CLASS type parameter's own class_typespec is NAMED.
// Every cell writes the SAME resolved class a DIFFERENT way, so the axis is the
// WRITTEN TEXT vs the RESOLVED CLASS.  No typedefs anywhere, so the group has
// no winner and the name can only be the resolved class's.
package q87;
  class qbase; int x; endclass
  class qpar #(type E = qbase); E e; endclass
endpackage
package p87c;
  import q87::*;
  class lbase; int y; endclass

  // (a) written = the resolved class's SIMPLE name (the control).
  class t_simple #(type A = lbase);
    A p;
  endclass
  // (b) written = a QUALIFIED name for a class in another package.
  class t_qual #(type A = q87::qbase);
    A p;
  endclass
  // (c) written = a WILDCARD-IMPORTED simple name from another package.
  class t_imp #(type A = qbase);
    A p;
  endclass
  // (d) the SECOND parameter is written as the FIRST parameter's name.
  class t_chain #(type A = lbase, type B = A);
    A pa;
    B pb;
  endclass
  // (e) written = a PARAMETERIZED class spelling.
  class t_spec #(type A = q87::qpar#(lbase));
    A p;
  endclass
  // (f) written = a parameterized spelling over the class's own parameter.
  class t_selfspec #(type A = lbase, type B = q87::qpar#(A));
    A pa;
    B pb;
  endclass
endpackage

module top87c;
  p87c::t_simple   #() b1;
  p87c::t_qual     #() b2;
  p87c::t_imp      #() b3;
  p87c::t_chain    #() b4;
  p87c::t_spec     #() b5;
  p87c::t_selfspec #() b6;
  // an OVERRIDE, written qualified.
  p87c::t_simple #(q87::qbase) b7;
endmodule
