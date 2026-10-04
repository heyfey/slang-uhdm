// § clsScopeFormalQualSpan234: an output formal (a direction keyword)
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    function void f(output types::rsrc_q_t rq);
    endfunction
  endclass
endpackage
