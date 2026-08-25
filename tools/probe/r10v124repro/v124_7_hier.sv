// r10v124 arm 7 — HIERARCHICAL, VIRTUAL-INTERFACE, STRUCT, CLASS-SCOPE and
// GEN-ARRAY receivers.  These reach Surelog through OTHER arms; the law must
// not move them unless golden does.
interface Duct;
  typedef int Flue[$];
  Flue Vents[string];
  Flue Grates[3];
endinterface

package Attic;
  typedef int Flue[$];
  typedef struct { Flue Panes[2]; Flue Sash[string]; } Frame;

  class Rafter;
    static Flue Beams[string];
    Frame Casing;
    function void raise(string kx);
      Beams[kx].push_back(701);
      Casing.Panes[1].push_back(702);
      Casing.Sash[kx].push_back(703);
      Rafter::Beams[kx].push_back(704);
      Attic::Rafter::Beams[kx].push_back(705);
    endfunction
  endclass

  Flue Joists[string];
endpackage

module Eaves #(parameter int SPAN = 2);
  typedef int Flue[$];
  Flue Slats[string];
  Duct dk();

  task poke(string kx);
    Attic::Joists[kx].push_back(706);
    dk.Vents[kx].push_back(707);
    dk.Grates[2].push_back(708);
    Slats[kx].push_back(709);
  endtask

  for (genvar gi = 0; gi < SPAN; gi++) begin : Bay
    Flue Cans[string];
    initial Cans["g"].push_back(710);
  end

  initial begin
    Bay[0].Cans["h"].push_back(711);
    poke("p");
  end
endmodule

module Roof;
  Eaves #(2) u_left();
  initial u_left.Slats["r"].push_back(712);
endmodule
