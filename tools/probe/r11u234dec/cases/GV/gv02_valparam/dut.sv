// § pureVirtRetSpecWholeSpan234: a pure virtual returning a value-parameter specialization vis#(4)
package p;
  virtual class vis #(int N = 1); endclass
  virtual class cs;
    pure virtual function vis#(4) get_v();
  endclass
endpackage
