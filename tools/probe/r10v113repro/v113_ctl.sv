// r10v113 / v113_ctl.sv — IN-BODY CONTROLS beside every cell.  The emitter's
// `classMethodNoBind` flag is toggled OFF inside an if/case CONDITION
// (StmtEmit:2408 "condition refs DO bind"), which once made the identical call
// bind differently one line apart; § controlBodyNoBind28 and
// § blkLocalSameCtrlDepthArgBinds57/64 live in the same window.  Every cell
// here is the SAME collision reached from a different control position.
package tctl;
  function automatic int Hasp(int n); return n + 1; endfunction
  task automatic Wedge(int n); endtask

  class Cage;
    int r;
    function int inIfCond();
      if (Hasp(1) > 0) return 1; else return 2;
    endfunction
    function int inIfBody();
      if (r > 0) return Hasp(2); return 0;
    endfunction
    function int inCaseExpr();
      case (Hasp(3)) 0: return 1; default: return 2; endcase
    endfunction
    function int inCaseItem();
      case (r) 0: return Hasp(4); default: return 0; endcase
    endfunction
    function int inWhile();
      int i = 0; while (i < Hasp(5)) i++; return i;
    endfunction
    function int inForBound();
      int a = 0; for (int i = 0; i < Hasp(6); i++) a += i; return a;
    endfunction
    function int inRepeat();
      int a = 0; repeat (Hasp(7)) a++; return a;
    endfunction
    function int inTernary();
      return (r > 0) ? Hasp(8) : Hasp(9);
    endfunction
    function int inNestedBlk();
      int a = 0;
      begin : blk
        int loc = Hasp(10);
        a = loc;
      end
      return a;
    endfunction
    task inDelay();
      #(Hasp(11)) Wedge(12);
    endtask
    task inEventCtl();
      Wedge(13);
    endtask

    // ---- the colliding members, all BELOW every caller above ----
    function int Hasp(int n); return n + 100; endfunction
    task Wedge(int n); endtask
  endclass
endpackage

module tb_ctl;
  import tctl::*;
  Cage c;
  initial begin c = new(); end
endmodule
