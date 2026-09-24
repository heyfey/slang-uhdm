// r10buvm29 arm E — the HOME of a written cast over a stream.
// in-body class method / OUT-OF-BLOCK class method / package function /
// module function / module initial / module always_comb / a task.  The head
// is an OUT-OF-BLOCK class method in a package (uvm_pkg's
// `function void uvm_tlm_generic_payload::do_unpack`).
package e29;
  typedef enum { Z0, Z1 } ze;
  class C;
    ze e1; int i1;
    function void inbody();
      bit __a[];
      e1 = ze'({ << bit { __a }});
    endfunction
    extern function void oob();
    extern task oobt();
  endclass
  function void C::oob();
    bit __a[];
    e1 = ze'({ << bit { __a }});            // OUT-OF-BLOCK -- the head's home
  endfunction
  task C::oobt();
    bit __a[];
    e1 = ze'({ << bit { __a }});
  endtask
  function automatic int pkgf();
    bit __a[];
    return int'({ << bit { __a }});
  endfunction
endpackage

module e29m;
  import e29::*;
  int m1;
  bit __b[];
  function automatic int mf();
    bit __a[];
    return int'({ << bit { __a }});
  endfunction
  task automatic mt();
    bit __a[];
    m1 = int'({ << bit { __a }});
  endtask
  initial begin
    m1 = int'({ << bit { __b }});
  end
  always_comb begin
    m1 = int'({ << bit { __b }});
  end
endmodule
