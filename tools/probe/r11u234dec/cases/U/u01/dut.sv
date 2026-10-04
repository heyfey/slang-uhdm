// § decode U (N0117): uvm_resource_pool's shape, a formal typed by another class's class-scope queue typedef, written cls::t without a direction
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    function void print_resources(types::rsrc_q_t rq, bit audit = 0);
    endfunction
  endclass
endpackage
