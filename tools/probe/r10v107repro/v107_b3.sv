// r10v107 arm b3 — UNBOUND-NAME SHAPES OUTSIDE the out-of-body class body:
// in-body methods, a package function, a module initial/always, a generate
// block, an interface and a program block.  The patch gates on
// `inClassBodyEmit && classBodyHomePkg75`, so NONE of these may move.
// MEASUREMENT ONLY.
package pb3;

  class d3;
    int fld;
  endclass

  class snk3;
    function int ask(d3 v); return 0; endfunction
  endclass

  class c3 #(type T = d3);
    snk3 s;
    d3   plain;
    // the IN-BODY twin of the exact moved shape
    function void ib_recvexpr();
      T v;
      if (s.ask(v) == 0) begin
      end
    endfunction
    extern function void oob_recvexpr();
  endclass

  function void c3::oob_recvexpr();
    T v;
    if (s.ask(v) == 0) begin
    end
  endfunction

  // a PACKAGE FUNCTION (no class body at all)
  function int pkgfn3(d3 a);
    d3 lv;
    lv = a;
    return 0;
  endfunction

endpackage

interface if3;
  logic ready;
  function int ifn3(int a);
    int lv;
    lv = a;
    return lv;
  endfunction
endinterface

program prog3;
  import pb3::*;
  initial begin
    int pv;
    pv = 0;
  end
endprogram

module topb3;
  import pb3::*;
  c3 #(d3) inst;
  logic clk;
  initial begin
    int mv;
    mv = 1;
    inst = new();
  end
  always @(posedge clk) begin
    int av;
    av = 2;
  end
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gblk
      logic gw;
      always @(posedge clk) gw <= 1'b0;
    end
  endgenerate
endmodule
