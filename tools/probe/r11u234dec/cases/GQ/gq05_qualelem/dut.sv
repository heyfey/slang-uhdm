// § clsTdClassElemRetSharesListing234: a package-qualified element (typedef q::el q_t[$])
package q;
  class el; endclass
endpackage
package p;
  class cont;
    typedef q::el q_t[$];
    q::el m[$];
    virtual function q_t get(); return m; endfunction
  endclass
endpackage
