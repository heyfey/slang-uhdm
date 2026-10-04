// § clsTdClassElemRetSharesListing234: a static method
package p;
  class el; endclass
  class cont;
    typedef el q_t[$];
    static el m[$];
    static function q_t get(); return m; endfunction
  endclass
endpackage
