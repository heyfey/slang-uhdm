// § clsTdClassElemRetSharesListing234: an extern prototype with an out-of-body definition returning cont::q_t
package p;
  class el; endclass
  class cont;
    typedef el q_t[$];
    el m[$];
    extern function q_t get();
  endclass
  function cont::q_t cont::get(); return m; endfunction
endpackage
