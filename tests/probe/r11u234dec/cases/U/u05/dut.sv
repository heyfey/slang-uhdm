// § decode U: u01 with a task and two formals of the class-scope type
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    task t(types::rsrc_q_t a, types::rsrc_q_t b);
    endtask
  endclass
endpackage
