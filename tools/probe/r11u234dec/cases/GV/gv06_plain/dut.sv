// § pureVirtRetSpecWholeSpan234: a pure virtual returning a plain class and one returning a two-argument specialization
package p;
  class comp; endclass
  virtual class vis #(type N = int, type M = int); endclass
  virtual class cs;
    pure virtual function comp get_c();
    pure virtual function vis#(comp, int) get_v2();
  endclass
endpackage
