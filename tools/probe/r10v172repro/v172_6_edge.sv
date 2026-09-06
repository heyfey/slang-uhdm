// r10v172 arm 6 — THE EDGES.  A subscript on the SECOND component (the law's
// declared residue R1); a subscript on the FIRST and on BOTH; a HIERARCHICAL
// task call through an instance whose name also names a package subroutine (a
// face where collapsing would destroy a real hierarchical reference); a system
// task statement; a `std::` call; a `randomize() with` statement; and an array
// of class handles.  MEASUREMENT ONLY.
package pv6172;
  function int idx6172(); return 1; endfunction
  function int u1172();   return 1; endfunction   // shares its name with an INSTANCE
  task     tsix172();     endtask

  class Leaf6172;
    string q172[$];
    rand int r172;
    function void one172(int a); endfunction
    function void none6172(); endfunction
  endclass

  class Mid6172;
    Leaf6172 arr172[4];
    Leaf6172 lf172;
    function new();
      lf172 = new();
      foreach (arr172[i]) arr172[i] = new();
    endfunction
  endclass

  class Probe6172;
    Mid6172  idx6172;          // the collapsing spelling
    Mid6172  midarr172[3];
    Leaf6172 tsix172;

    function new();
      idx6172 = new();
      tsix172 = new();
      foreach (midarr172[i]) midarr172[i] = new();
    endfunction

    function void edges172();
      // v6_01 a subscript on the SECOND component — residue R1
      idx6172.arr172[1].one172(5);
      // v6_02 a subscript on the SECOND component, no argument
      idx6172.arr172[2].none6172();
      // v6_03 a subscript on the FIRST component of a THREE-name chain
      midarr172[0].lf172.one172(6);
      // v6_04 a subscript on the FIRST and the SECOND
      midarr172[1].arr172[3].one172(7);
      // v6_05 a plain TWO-name chain on the same receiver (the control)
      tsix172.one172(8);
      // v6_06 a THREE-name chain, no subscript anywhere (the control)
      idx6172.lf172.one172(9);
      // v6_07 a SYSTEM task statement
      $display("v6_07 %0d", tsix172.r172);
      // v6_08 randomize() with, in statement position
      void'(tsix172.randomize() with { r172 > 0; });
      // v6_09 a queue method on a two-name chain
      tsix172.q172.push_back("v6_09");
    endfunction
  endclass
endpackage

module leafv6172;
  import pv6172::*;
  task ttask172();
    Leaf6172 tsix172;
    tsix172 = new(); tsix172.q172.push_back("v6_10");   // v6_10
  endtask
endmodule

module topv6172;
  import pv6172::*;
  leafv6172 u1172();                 // an INSTANCE whose name is also a package function

  // v6_11 — a HIERARCHICAL task call through that instance, from inside a task
  task drive172();
    u1172.ttask172();
  endtask

  pv6172::Probe6172 p172;
  initial begin
    p172 = new();
    p172.edges172();
    drive172();
  end
endmodule
