// r10v124 arm 12 — CONTROL for the class-property-vs-package-variable name
// collision: the SAME class property is referenced with a select (the law's
// cell) and WITHOUT one (the pre-existing binder's cell) in the SAME method.
package Tannery2;
  typedef int Hide[$];
  Hide Vatt[string];
  Hide Bare;

  class Currier2;
    Hide Vatt[string];
    Hide Bare;
    task plain(string kx);
      Vatt[kx].push_back(1201);   // the LAW's cell (indexed receiver)
      Bare.push_back(1202);       // CONTROL: same collision, NO select
      Vatt.delete(kx);            // CONTROL: collision on the ARRAY itself
    endtask
  endclass
endpackage

module Tanyard2;
  import Tannery2::*;
  Tannery2::Currier2 cu;
  initial begin cu = new(); cu.plain("c"); end
endmodule
