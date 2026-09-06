// r10v173 arm W — ORDER, CASE and ARITY.  The same three packages as arm B's
// shape but declared in a DIFFERENT source order (callee package LAST), with
// mixed-case names, a name that is a strict PREFIX of another package's name,
// and functions of 0, 1 and 3 arguments — so a gate that matched a prefix
// rather than the whole qualifier, or that depended on declaration order,
// shows up here.  `Ash` is a strict prefix of `AshPile_pkg`.
package Cinder_Pkg;
  // calls into a package DECLARED LATER in the file (Ash) and into one whose
  // name has Cinder_Pkg's own name as a prefix.
  function automatic int unsigned Ember0();
    return 41;
  endfunction
  function automatic int unsigned Ember1(int unsigned a);
    return a + 42;
  endfunction
  function automatic int unsigned Ember3(int unsigned a, int unsigned b, int unsigned c);
    return a + b + c + 43;
  endfunction
  function automatic int unsigned Kindle(int unsigned a);
    // own package: bare, qualified, and the three arities
    return Ember0() + Ember1(a) + Cinder_Pkg::Ember1(a)
         + Ember3(a, 1, 2) + Cinder_Pkg::Ember3(a, 3, 4)
         + Cinder_Pkg::Ember0();
  endfunction
endpackage

package Ash;
  function automatic int unsigned Soot(int unsigned a);
    return a + 51;
  endfunction
  function automatic int unsigned Flake(int unsigned a);
    // qualified into a package declared EARLIER, and bare into its own.
    return Cinder_Pkg::Ember1(a) + Soot(a) + Ash::Soot(a);
  endfunction
endpackage

package AshPile_pkg;
  import Ash::*;
  function automatic int unsigned Heap(int unsigned a);
    // `Ash::Soot` is package-qualified; `Soot` reaches the same function
    // through the wildcard import; `AshPile_pkg::Heap` is self-recursive and
    // qualified with a name of which `Ash` is a strict PREFIX.
    if (a == 0) return 0;
    return Ash::Soot(a) + Soot(a) + AshPile_pkg::Heap(a - 1);
  endfunction
endpackage

module cinder_top (output int unsigned c1, output int unsigned c2, output int unsigned c3);
  assign c1 = Cinder_Pkg::Kindle(2);
  assign c2 = Ash::Flake(3);
  assign c3 = AshPile_pkg::Heap(2);
endmodule
