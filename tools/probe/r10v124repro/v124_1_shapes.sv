// r10v124 arm 1 — RECEIVER SHAPES.  Names deliberately unlike each other and
// unlike any letter scheme, so an agreeing cell cannot be a naming artefact.
package Quarry;
  typedef int Tally[$];

  class Nugget;
    int worth;
    function void addto(int amt); worth += amt; endfunction
    task stow(int amt); worth = amt; endtask
  endclass

  class Seam;
    Tally  Pocket[string];
    Tally  Drift[int];
    Tally  Chute[];
    Tally  Braid[$];
    Tally  Bench[4];
    Tally  Lattice[3][5];
    Nugget Roster[string];
    Nugget Solo;
    Tally  Flat;

    function void grind(string kx, int ix);
      Pocket[kx].push_back(11);
      Drift[ix].push_back(12);
      Chute[ix].push_back(13);
      Braid[0].push_back(14);
      Braid[$].push_back(15);
      Bench[2].push_back(16);
      Lattice[1][3].push_back(17);
      Roster[kx].addto(18);
      Solo.addto(19);
      Flat.push_back(20);
    endfunction
  endclass
endpackage

module Kiln;
  Quarry::Seam sc;
  initial begin
    sc = new();
    sc.Chute = new[4];
    sc.grind("ore", 1);
  end
endmodule
