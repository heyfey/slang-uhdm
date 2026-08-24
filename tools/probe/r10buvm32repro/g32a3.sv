// r10buvm32repro/g32a3.sv — the TASK half and the NEGATIVE CONTROLS.
// The gate this pass tightens is shared by the func_call and task_call arms,
// so an out-of-body static TASK is exercised with the same four qualifier
// spellings; and every cell that must NOT move (a resolvable scoped call in
// each position, an in-body callee, a package free function, an implicit-this
// call, a `super.` call, a receiver-qualified method call) is written beside
// them so the boundary is visible in one file.
package r32;

  class tbase32;
    static int thits32;
    extern static task tbt32(int a);
    static task tbinb32(int a); thits32 += a; endtask
  endclass
  task tbase32::tbt32(int a); thits32 += a; endtask

  class tder32 extends tbase32;
    typedef tder32 tself32;
    extern static task tdt32(int a);
    static task tdinb32(int a); thits32 += a; endtask
    extern static task trun32(int a);
    extern static function int tfun32(int a);
    task inbrun32(int a);
      tder32::tdt32(a);          // T9  own name / out-of-body TASK
      tself32::tdt32(a);         // T10 alias    / out-of-body TASK
    endtask
  endclass
  task tder32::tdt32(int a); thits32 += a; endtask
  function int tder32::tfun32(int a); return a; endfunction

  task tder32::trun32(int a);
    int r;
    tder32::tdt32(a);            // T1  own name / out-of-body TASK  -> task_call
    tself32::tdt32(a);           // T2  alias    / out-of-body TASK  -> ref_obj
    tbase32::tbt32(a);           // T3  base name / out-of-body TASK -> task_call
    tder32::tbt32(a);            // T4  derived name / base's TASK   -> ref_obj
    tder32::tdinb32(a);          // T5  own name / IN-BODY TASK      -> ref_obj
    tself32::tdinb32(a);         // T6  alias    / IN-BODY TASK      -> ref_obj
    r = tder32::tfun32(a);       // T7  own name / out-of-body FUNCTION
    r = tself32::tfun32(a);      // T8  alias    / out-of-body FUNCTION
    $display("%0d", r);
  endtask

  // NEGATIVE CONTROLS — none of these is a `::`-scoped call and none may move.
  function int rfree32(int a); return a + 1; endfunction

  class ctl32;
    int p32c;
    function new(); p32c = 0; endfunction
    function int m32(int a); return a + p32c; endfunction
    function int callers32(int a);
      int r;
      ctl32 h = new();
      r = m32(a);                // C1 implicit-this call
      r += this.m32(a);          // C2 explicit this
      r += h.m32(a);             // C3 receiver-qualified method call
      r += rfree32(a);           // C4 package free function, unqualified
      r += r32::rfree32(a);      // C5 package free function, package-qualified
      return r;
    endfunction
  endclass

  class ctlsub32 extends ctl32;
    function new(); super.new(); endfunction     // C6 super.new
    function int m32(int a); return super.m32(a) + 1; endfunction  // C7 super call
  endclass
endpackage

module g32a3;
  int r;
  initial begin
    r32::tder32::trun32(3);      // U1 pkg::Class::task, out-of-body -> ref_obj
    r32::tbase32::tbinb32(4);    // U2 pkg::Class::task, IN-BODY     -> ref_obj
    r = r32::rfree32(5);         // U3 package free function CONTROL
    $display("%0d", r);
  end
endmodule
