// r10v110 arm v6 — ODD SPELLINGS: a delay- / event-controlled dotted `new[]`,
// a STATIC local inside an automatic subroutine, a static class method home,
// a dotted `new[]` whose size reads ANOTHER dotted member, and a sequence of
// two dotted `new[]` on one line.
package Ok6;
  class Gz6;
    int  a6[];
    byte b6[];
    Gz6  n6;
    int  s6;
    int  w6;
    static Gz6 SH6;
    static function void smeth6(Gz6 h6);
      h6.a6 = new [3];        // v6h01 STATIC class method home   (in law)
      h6.s6 = 3;              // v6h02 control
    endfunction
  endclass
endpackage

module v6top;
  import Ok6::*;
  logic ck6;
  Gz6 g6;
  int  q6[];

  initial begin
    g6 = new(); g6.n6 = new(); g6.w6 = 2;
    #1 g6.a6 = new [4];              // v6h03 DELAYED dotted new[]        (in law?)
    @(posedge ck6) g6.b6 = new [5];  // v6h04 EVENT-CONTROLLED dotted     (in law?)
    g6.a6 = new [g6.w6];             // v6h05 size reads ANOTHER member   (in law)
    g6.a6 = new [4]; g6.b6 = new [5];// v6h06/07 two on one line          (in law)
    g6.n6.a6 = new [g6.n6.w6];       // v6h08 two-dot both sides          (in law)
    Gz6::SH6 = new();
    Gz6::smeth6(g6);
    #1 g6.s6 = 6;                    // v6h09 delayed plain               (control)
    @(posedge ck6) g6.s6 = 7;        // v6h10 event-controlled plain      (control)
  end

  task automatic tstat6();
    static Gz6 sl6 = null;
    if (sl6 == null) sl6 = new();
    sl6.a6 = new [8];                // v6h11 STATIC local in an automatic task (in law)
    sl6.s6 = 8;                      // v6h12 control
  endtask
endmodule
