// r10vbuvm24repro/gv24g.sv — THE INTERACTION GRID: a written-but-empty slot in
// the SAME call as an actual whose BINDING is governed by one of the standing
// bind-window laws (§ classArgBind12, § controlBodyNoBind28,
// § blkLocalSameCtrlDepthArgBinds57/64, § pkgVarBindsOnlyThroughInstance88,
// § collArgNamedBlkLocalNoBind15, § formalDefaultBindsLikeBody13,
// § classInBodyRecvCallArgNoBind52, § superNewFormalBinds28,
// § newArrayArgNoBind16).  The boundary arms prove those windows unchanged
// when NO slot is empty; this file is the only place they meet.
// MEASUREMENT ONLY.
package pw24;
  int pkgvar = 3;
  typedef enum int { W0 = 0, W1 = 4 } ew_t;

  function automatic int w3(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction

  class base24w;
    int bx;
    function new(int a = 1, int b = 2, int c = 3); bx = a + b + c; endfunction
  endclass

  class cw24 extends base24w;
    int fld;
    int arr[];
    function new(int a = 1, int b = 2, int c = 3);
      super.new(a,,c);
      arr = new[4];
    endfunction
    function int meth(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
    function int caller(int p = 1, int q = 2);
      int r = 0;
      int loc = 5;
      cw24 o = new();
      // a CLASS FIELD as an actual, next to an empty slot
      r += w3(fld,,3);
      // a FORMAL of the enclosing method as an actual
      r += w3(p,,q);
      // a PACKAGE variable as an actual
      r += w3(pkgvar,,3);
      // a method RECEIVER call with an empty slot
      r += o.meth(fld,,loc);
      // inside a CONTROL BODY
      if (p > 0) begin
        r += w3(loc,,3);
      end
      for (int i = 0; i < 2; i++) begin
        int inner = i;
        r += w3(inner,,3);
      end
      // inside a NAMED BLOCK with a block-local
      begin : nb24
        int nbl = 7;
        r += w3(nbl,,3);
        r += meth(nbl,,loc);
      end
      // a dynamic-array element and a NEW[] size next to an empty slot
      arr = new[loc];
      r += w3(arr[0],,3);
      // an enum member and a hierarchical-ish select as actuals
      r += w3(int'(W1),,arr[1]);
      return r;
    endfunction
  endclass
endpackage

module topw24;
  import pw24::*;
  cw24 h;
  int rr;
  int marr [4];
  initial begin
    h = new(1,,3);
    rr  = h.caller(1,);
    rr += w3(marr[2],,3);
    rr += w3(pkgvar,,marr[1]);
  end
endmodule
