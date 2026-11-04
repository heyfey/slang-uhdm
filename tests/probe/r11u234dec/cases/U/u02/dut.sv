// § decode U: u01 with a direction keyword (input types::rsrc_q_t rq)
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    function void print_resources(input types::rsrc_q_t rq, bit audit = 0);
    endfunction
  endclass
endpackage
