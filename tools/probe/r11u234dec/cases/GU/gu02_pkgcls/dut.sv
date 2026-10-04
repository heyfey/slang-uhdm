// § clsScopeFormalQualSpan234: a package-and-class qualified formal type (p::types::rsrc_q_t)
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
endpackage
package r;
  class pool;
    function void f(p::types::rsrc_q_t rq);
    endfunction
  endclass
endpackage
