// r10buvm12 arm v2_reach12 — THE REACH FENCE for the callee-link law.
// Everything here is a NEIGHBOUR of arm v1's converted cells: a prototype
// reached through INHERITANCE, through a RECEIVER, through a CLASS-SCOPE
// qualifier, from a class in a MODULE and at $unit, plus the property-init
// variants v1 did not cover.  These cells say where the law must STOP.
package p2;

  virtual class base2;
    extern virtual function int bef();          // extern proto in the BASE
    pure virtual function int bpv();             // pure proto in the BASE
    function int bpm(); return 1; endfunction    // plain in-body in the BASE
  endclass
  function int base2::bef(); return 2; endfunction

  class der2 extends base2;
    function int bpv(); return 3; endfunction
    // INHERITED prototypes, called unqualified from the DERIVED class body
    function int call_bef(); return bef(); endfunction
    function int call_bpv(); return bpv(); endfunction
    function int call_bpm(); return bpm(); endfunction
  endclass

  virtual class recv2;
    extern virtual function int ref2();
    extern static function int rst2();
    function int pm2(); return 4; endfunction
  endclass
  function int recv2::ref2(); return 5; endfunction
  function int recv2::rst2(); return 6; endfunction

  class user2;
    recv2 h;
    // a RECEIVER call and a CLASS-SCOPE QUALIFIED static call to prototypes
    function int call_recv();  return h.ref2();    endfunction
    function int call_qual();  return recv2::rst2(); endfunction
    function int call_recvpm(); return h.pm2();    endfunction
  endclass

  // a PROPERTY initializer whose callee is a PLAIN in-body method, above and
  // below the property (v1 only covered prototype callees here)
  class prop2;
    static function int pa2(); return 8; endfunction
    static int q_above = pa2();
    static int q_below = pb();
    static function int pb(); return 9; endfunction
  endclass

  // an extern TASK prototype, called from an in-body TASK (v1's call_ek twin,
  // kept here so the FUNCTION law and the TASK-KIND residue are measured in
  // separate arms)
  class task2;
    extern task tk2();
    task call_tk(); tk2(); endtask
  endclass
  task task2::tk2(); endtask
endpackage

module m2;
  // the SAME shape in a class declared inside a MODULE
  virtual class mc2;
    extern virtual function int mef();
    pure virtual function int mpv();
    function int call_mef(); return mef(); endfunction
    function int call_mpv(); return mpv(); endfunction
  endclass
  function int mc2::mef(); return 10; endfunction
  p2::der2 dh;
  initial dh = null;
endmodule
