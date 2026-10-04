// § clsScopeFormalQualSpan234: a task formal with no direction and a default beside it
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    task t(types::rsrc_q_t rq, int k = 3);
    endtask
  endclass
endpackage
