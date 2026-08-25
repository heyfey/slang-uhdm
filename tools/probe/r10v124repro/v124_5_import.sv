// r10v124 arm 5 — IMPORT CLONES (uvm122's home-binding fence) and 1-3
// INSTANCES of the same module.
package Origin;
  typedef shortint Coil[$];

  class Rotor;
    Coil Windings[string];
    Coil Poles[3];
    function void spin(string kx);
      Windings[kx].push_back(101);
      Poles[2].push_back(102);
    endfunction
  endclass

  Coil Bench[string];
  function void bench_push(string kx);
    Bench[kx].push_back(103);
  endfunction
endpackage

package Echoed;
  import Origin::*;
  export Origin::*;
  typedef shortint Coil2[$];
  Coil2 Mirror[string];
  function void mirror_push(string kx);
    Mirror[kx].push_back(201);
    Bench[kx].push_back(202);
  endfunction
endpackage

module Cell;
  import Echoed::*;
  import Origin::*;
  Origin::Rotor rt;
  initial begin
    rt = new();
    rt.spin("one");
    mirror_push("two");
    bench_push("three");
  end
endmodule

module Trio;
  Cell u_first();
  Cell u_second();
  Cell u_third();
endmodule
