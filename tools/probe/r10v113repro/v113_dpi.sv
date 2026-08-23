// r10v113 / v113_dpi.sv — exotic callees: a DPI import of the colliding name, a
// covergroup body, and a specialised parameterised class.  If golden ever leaves
// such a call UNBOUND while a package subroutine of the name exists, the widened
// fall-back would bind it and that would be an AWAY-GOLDEN.
package vexo;
  import "DPI-C" function int Flange(input int n);
  function automatic int Louver(int n); return n + 1; endfunction
  function automatic int Trunnion(int n); return n + 2; endfunction

  class Dpi;
    function int callsDpi(); return Flange(1); endfunction
    function int Flange(int n); return n + 100; endfunction
  endclass

  class Cov;
    int q;
    covergroup cg;
      option.per_instance = 1;
      cp: coverpoint q { bins lo = {[0:9]}; }
    endgroup
    function new(); cg = new(); q = Louver(2); endfunction
    function int sampleIt(); cg.sample(); return Louver(3); endfunction
    function int Louver(int n); return n + 110; endfunction
  endclass

  class Par #(type T = int, int W = 4);
    function int pcall(); return Trunnion(4); endfunction
    function int Trunnion(int n); return n + W; endfunction
  endclass

  typedef Par #(bit, 8)  ParA;
  typedef Par #(byte, 9) ParB;
endpackage

module tb_exo;
  import vexo::*;
  Dpi d; Cov c; ParA pa; ParB pb;
  initial begin d = new(); c = new(); pa = new(); pb = new(); end
endmodule
