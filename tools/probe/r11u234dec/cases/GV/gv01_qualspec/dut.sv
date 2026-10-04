// § pureVirtRetSpecWholeSpan234: a pure virtual returning a package-qualified specialization
package q;
  virtual class vis #(type N = int); endclass
endpackage
package p;
  class comp; endclass
  virtual class cs;
    pure virtual function q::vis#(comp) get_v();
  endclass
endpackage
