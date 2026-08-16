// r10sd9 GRID CELL g5 — a TYPEDEF CHAIN (typedef of a typedef) to a class and
// to an int.  § tdChainNoClone43 refuses to clone a chained atom typedef, so
// the int arm must bind the LISTING object and not a clone; the class arm has
// no clone rule at all.
package pv;
  class kv;
    int xv;
  endclass
  typedef kv tv1;
  typedef tv1 tv2;
  typedef int ti1;
  typedef ti1 ti2;
  class cv;
    tv2 a_cls [string];
    tv2 s_cls;
    ti2 a_int [string];
    ti2 s_int;
  endclass
endpackage
module topv;
  pv::cv hv;
endmodule
