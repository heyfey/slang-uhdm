// r10uvm150 arm B — CONTROLS + the boundary of "the receiver is a call".
// Different naming style, different order, different numbers from arm A.
package QQ8;
  class NODE_2;
    int V = 3;
    int tbl[3];
    function int GO(int a, int b); return a*b+V; endfunction
    function int NIL(); return V; endfunction
    function NODE_2 nxt(); return this; endfunction
  endclass

  class BLD;
    extern static function NODE_2 OB();       // out-of-body: keeps func_call
    static function NODE_2 IB(int w);         // in-body: degrades to ref_obj
      NODE_2 n = new(); n.V = w; return n;
    endfunction
  endclass
  function NODE_2 BLD::OB(); NODE_2 n = new(); return n; endfunction

  function NODE_2 freeN();  NODE_2 n = new(); return n; endfunction
  function int    freeI(int u); return u+1; endfunction
endpackage

module TOPB;
  import QQ8::*;
  NODE_2 hd;
  NODE_2 vec[2];
  int    o1,o2,o3,o4,o5,o6,o7,o8,o9;

  // B1  standalone scoped call, NO chain  (span control for the func_call)
  function int b01(); return BLD::OB().V; endfunction
  function automatic NODE_2 b02(); return BLD::OB(); endfunction
  // B3  standalone BARE call, NO chain    (span control)
  function automatic NODE_2 b03(); return freeN(); endfunction
  // B4  BARE call receiver + 2-arg method
  function int b04(); return freeN().GO(4,5); endfunction
  // B5  variable-rooted THREE-element chain (hier_path road, must NOT move)
  function int b05(); return hd.nxt().GO(6,7); endfunction
  // B6  variable receiver, ZERO-arg method (control)
  function int b06(); return hd.NIL(); endfunction
  // B7  (moved to g150_e.sv: Surelog REFUSES `Cls::f().name[i]` at the grammar)
  // B8  scoped call receiver with ARGS, 3-arg-free method
  function int b08(); return BLD::IB(9).NIL(); endfunction
  // B9  (moved to g150_e.sv: Surelog REFUSES a two-deep `.a().b()` chain)
  // B10 (moved to g150_e.sv: same grammar refusal on a bare receiver)
  // B11 built-in method on a queue (control, must NOT move)
  int qq[$];
  function int b11(); return qq.size(); endfunction
  // B12 (moved to g150_e.sv: Surelog REFUSES `Cls::f().arr.sum()`)
  // B13 scoped call inside a $display argument
  task b13(); $display("%0d", BLD::OB().GO(8,9)); endtask
  // B14 THREE separate instances of the same shape on one line
  function int b14(); return BLD::OB().NIL() + BLD::OB().NIL() + freeI(2); endfunction
  // B15 scoped call receiver in an ASSIGNMENT Rhs, statement home = module
  initial begin
    hd = new();
    o1 = BLD::OB().GO(2,3);
    BLD::OB().GO(3,4);
    o2 = b01();
  end
endmodule
