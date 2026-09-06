// r10v173 arm U — NEGATIVE CONTROL.  Nothing here lives in a package DEF
// listing calling a package function, so the gate must move NO cell: module
// subroutines calling each other, a module function calling a package function,
// an interface subroutine, a class outside any package, system calls, and a
// generate block.  If any cell moves here the gate over-fires.
package lanternPkg;
  function automatic int unsigned beam(int unsigned n);
    return n + 13;
  endfunction
endpackage

class Wanderer;                      // $unit-scope class, no package home
  int unsigned paces;
  function new(); paces = 0; endfunction
  function int unsigned trek(int unsigned n);
    return lanternPkg::beam(n) + n;
  endfunction
endclass

interface glow_if (input logic clk);
  function automatic int unsigned lumens(int unsigned n);
    return lanternPkg::beam(n) + 1;
  endfunction
endinterface

module lantern_top (input logic clk, output int unsigned g1, output int unsigned g2,
                    output int unsigned g3);
  glow_if u_if (.clk(clk));

  function automatic int unsigned localHelp(int unsigned n);
    return n * 2;
  endfunction
  function automatic int unsigned localCaller(int unsigned n);
    return localHelp(n) + lanternPkg::beam(n);   // module fn -> pkg fn
  endfunction
  task automatic localTask(input int unsigned n, output int unsigned o);
    o = localHelp(n);
  endtask

  Wanderer w;
  int unsigned tv;
  int unsigned wv;
  initial begin
    w = new();
    localTask(3, tv);
    wv = w.trek(1);
  end

  assign g1 = localCaller(5) + $bits(int) + $clog2(64);
  assign g2 = u_if.lumens(2) + tv;

  genvar gi;
  int unsigned gsum [0:1];
  generate
    for (gi = 0; gi < 2; gi++) begin : g_blk
      assign gsum[gi] = lanternPkg::beam(gi) + localHelp(gi);
    end
  endgenerate
  assign g3 = gsum[0] + gsum[1] + wv;
endmodule
