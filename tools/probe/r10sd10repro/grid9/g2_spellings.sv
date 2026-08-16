// r10sd9 GRID CELL g2 — ONE class-handle typedef, ALL FOUR array spellings
// (assoc, dynamic, queue, fixed) plus the scalar.  The fixed spelling reaches
// classFixedElemVar6 and the other three reach classAssocElemVar, so this cell
// is what says the law is spelling-independent at class scope.
package py;
  class ky;
    int xy;
  endclass
  typedef ky tcy;
  class cy;
    tcy sc;
    tcy aa [string];
    tcy ad [];
    tcy aq [$];
    tcy af [4];
  endclass
endpackage
module topy;
  py::cy hy;
endmodule
