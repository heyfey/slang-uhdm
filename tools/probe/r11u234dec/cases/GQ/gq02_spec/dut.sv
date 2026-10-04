// § clsTdClassElemRetSharesListing234: a specialization element (typedef box#(int) q_t[$])
package p;
  class box #(type T = int); endclass
  class cont;
    typedef box#(int) q_t[$];
    box#(int) m[$];
    virtual function q_t get(); return m; endfunction
  endclass
endpackage
