// r10uvm151 arm C — HOMES.  The same three law cells (a `with` array method, a
// keyword array method and a randomize-with) written in every scope a
// subroutine body can live in, plus TWO INSTANCES of one module and a package
// that WILDCARD-IMPORTS another (the copy vs the original).
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.
package pkC151;
  class itC151;
    rand int rv;
    int offset;
  endclass
  int  freeq_c151[$];
  bit  freeb_c151[$];
  // free package FUNCTION
  function void freefn_c151();
    int lq[$];
    itC151 o;
    lq.sort() with ( item );
    lq.unique();
    o.randomize() with { rv > 0; };
  endfunction
  // free package TASK
  task freetk_c151();
    freeq_c151.sort() with ( item );
    freeb_c151.and();
  endtask
  class homecls_c151;
    int cq_c151[$];
    itC151 co;
    // IN-BODY class method
    task ib_c151;
      cq_c151.sort() with ( item );
      cq_c151.unique();
      co.randomize() with { rv > 1; };
    endtask
    // OUT-OF-BODY class method and task (declared here, defined below)
    extern function void oob_fn_c151();
    extern task oob_tk_c151();
    // CLASS CONSTRUCTOR
    function new();
      cq_c151.rsort() with ( item );
    endfunction
  endclass
  function void homecls_c151::oob_fn_c151();
    cq_c151.sort() with ( item );
    cq_c151.unique();
  endfunction
  task homecls_c151::oob_tk_c151();
    cq_c151.find_index() with ( item > 0 );
    co.randomize() with { rv > 2; };
  endtask
endpackage
package pkC151imp;
  import pkC151::*;
  export pkC151::*;
endpackage
module modhome_c151;
  int mq_c151[$];
  bit mb_c151[$];
  function void modfn_c151();
    mq_c151.sort() with ( item );
    mb_c151.xor();
  endfunction
  task modtk_c151();
    mq_c151.find_first() with ( item > 0 );
    mq_c151.unique();
  endtask
  initial begin
    mq_c151.sort() with ( item );
    mb_c151.or();
  end
  always @(*) begin
    mq_c151.rsort() with ( item );
  end
endmodule
program proghome_c151;
  int pq_c151[$];
  function void progfn_c151();
    pq_c151.sort() with ( item );
    pq_c151.unique();
  endfunction
endprogram
interface ifhome_c151;
  int fq_c151[$];
  function void iffn_c151();
    fq_c151.sort() with ( item );
    fq_c151.unique();
  endfunction
endinterface
module topC151;
  modhome_c151 inst_a_c151();
  modhome_c151 inst_b_c151();
  ifhome_c151  ifc_c151();
endmodule
