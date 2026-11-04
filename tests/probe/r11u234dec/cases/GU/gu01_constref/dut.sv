// § clsScopeFormalQualSpan234: `const ref cls::t` (a direction: the whole name)
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    function void f(const ref types::rsrc_q_t rq);
    endfunction
  endclass
endpackage
