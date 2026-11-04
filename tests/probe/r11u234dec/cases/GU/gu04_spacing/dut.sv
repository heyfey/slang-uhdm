// § clsScopeFormalQualSpan234: blanks around the scope operator (types :: rsrc_q_t)
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    function void f(types :: rsrc_q_t rq);
    endfunction
  endclass
endpackage
