// r10v110 arm v4 — the BIND-WINDOW replay (buvm13/15/28/57/64/88) carried on a
// dotted dyn-array `new[]`: formal default, return-name receiver collapse,
// collection-arg named-block local, control body, block-local at the same
// control depth, package var through an instance.
package Bp4;
  class Vv4;
    int  d4[];
    byte e4[];
    Vv4  n4;
    int  s4;
  endclass
  Vv4 PKGV4;
  int PKGARR4[];

  // formal DEFAULT carrying a dotted new[] receiver (§ formalDefaultBindsLikeBody13)
  function void fdef4(int w4 = 3, Vv4 hv4 = null);
    if (hv4 != null) hv4.d4 = new [w4];       // v4e01 formal default home (in law)
  endfunction

  // return-name receiver (§ retNameRecvCollapseArgsBindLikeBody15)
  function Vv4 mk4(int k4);
    mk4 = new();
    mk4.d4 = new [k4];                        // v4e02 RETURN NAME receiver (in law)
    mk4.s4 = k4;                              // v4e03 control
  endfunction

  // collection-arg + NAMED BLOCK local (§ collArgNamedBlkLocalNoBind15)
  function void coll4(int a4[$]);
    begin : NB4
      Vv4 nbl4;
      nbl4 = new();
      nbl4.e4 = new [a4.size()];              // v4e04 named-blk local recv (in law)
      nbl4.s4 = a4.size();                    // v4e05 control
    end
  endfunction

  // control BODY, and a block local at the SAME control depth
  // (§ controlBodyNoBind28 / § blkLocalSameCtrlDepthArgBinds57/64)
  function void ctrl4(int c4);
    if (c4 > 0) begin
      Vv4 cb4;
      cb4 = new();
      cb4.d4 = new [c4];                      // v4e06 control-body local  (in law)
    end
    for (int i4 = 0; i4 < 2; i4++) begin
      Vv4 lb4;
      lb4 = new();
      lb4.e4 = new [i4];                      // v4e07 loop-body local     (in law)
    end
  endfunction

  // package var reached THROUGH an instance (§ pkgVarBindsOnlyThroughInstance88)
  task pkgv4();
    PKGV4 = new();
    PKGV4.d4 = new [2];                       // v4e08 package handle prop (in law)
    PKGARR4  = new [3];                       // v4e09 package array UNDOT (control)
  endtask
endpackage

module v4top;
  import Bp4::*;
  Vv4 mv4;
  initial begin
    mv4 = mk4(4);
    fdef4(5, mv4);
    coll4('{1,2});
    ctrl4(1);
    pkgv4();
    mv4.d4 = new [6];                         // v4e10 module initial      (in law)
  end
endmodule
