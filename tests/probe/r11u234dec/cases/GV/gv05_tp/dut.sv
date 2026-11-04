// § pureVirtRetSpecWholeSpan234: a pure virtual returning the class's own type parameter
package p;
  class comp; endclass
  virtual class cs #(type T = comp);
    pure virtual function T get_t();
  endclass
endpackage
