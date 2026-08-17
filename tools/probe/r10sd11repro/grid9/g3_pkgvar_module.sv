// r10sd9 GRID CELL g3 — THE makeTypespec HALF.  The same class-handle typedef
// used by a PACKAGE variable and by a MODULE variable, in every array spelling
// plus the scalar.  No class property anywhere in this cell, so it scores
// § arrayElemTdIsScalarTd9 alone.
package pz;
  class kz;
    int xz;
  endclass
  typedef kz tcz;
  tcz p_s;
  tcz p_a [string];
  tcz p_d [];
  tcz p_q [$];
endpackage
module topz;
  import pz::*;
  tcz m_s;
  tcz m_a [string];
  tcz m_d [];
  tcz m_q [$];
endmodule
