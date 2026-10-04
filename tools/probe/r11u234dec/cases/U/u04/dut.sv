// § decode U: u01 with the formal in a package function (no class)
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  function void print_resources(types::rsrc_q_t rq);
  endfunction
endpackage
