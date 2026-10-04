// § clsScopeFormalQualSpan234: an extern prototype and its out-of-body definition
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    extern function void f(types::rsrc_q_t rq);
  endclass
  function void pool::f(types::rsrc_q_t rq);
  endfunction
endpackage
