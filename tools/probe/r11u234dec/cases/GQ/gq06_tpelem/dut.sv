// § clsTdClassElemRetSharesListing234: an element written as the class's own type parameter (the twin kept)
package p;
  class el; endclass
  class cont #(type T = el);
    typedef T q_t[$];
    T m[$];
    virtual function q_t get(); return m; endfunction
  endclass
endpackage
