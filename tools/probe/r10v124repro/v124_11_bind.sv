// r10v124 arm 11 — NAME COLLISIONS the new bare name can now bind to: a
// package variable vs a FORMAL of the same name, vs a subroutine LOCAL of the
// same name, and a class property vs a task formal.  (uvm81's
// pkgSubRefBindsPkgVarOverFormal81 territory: the rename is what makes these
// references bindable at all.)
package Tannery;
  typedef int Hide[$];

  Hide Vatt[string];
  Hide Rack[2];

  // FORMAL shares the package variable's name.
  function void byformal(Hide Vatt[string], string kx);
    Vatt[kx].push_back(1101);
  endfunction

  // LOCAL shares the package variable's name.
  function void bylocal(string kx);
    Hide Rack[2];
    Rack[0].push_back(1102);
  endfunction

  // Neither: the package variable itself.
  function void bypkg(string kx);
    Vatt[kx].push_back(1103);
    Rack[1].push_back(1104);
  endfunction

  class Currier;
    Hide Vatt[string];
    task scrape(Hide Vatt[string], string kx);
      Vatt[kx].push_back(1105);
    endtask
    task plain(string kx);
      Vatt[kx].push_back(1106);
    endtask
  endclass
endpackage

module Tanyard;
  import Tannery::*;
  Tannery::Currier cu;
  Hide Local[string];
  initial begin
    cu = new();
    bypkg("a");
    bylocal("b");
    cu.plain("c");
    Local["d"].push_back(1107);
  end
endmodule
