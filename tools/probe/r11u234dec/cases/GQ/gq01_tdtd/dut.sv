// § clsTdClassElemRetSharesListing234: the element written with a class typedef (typedef el e2_t; typedef e2_t q_t[$])
package p;
  class el; endclass
  class cont;
    typedef el e2_t;
    typedef e2_t q_t[$];
    el m[$];
    virtual function q_t get(); return m; endfunction
  endclass
endpackage
