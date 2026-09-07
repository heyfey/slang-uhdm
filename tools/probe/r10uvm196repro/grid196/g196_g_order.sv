// r10uvm196 arm G — THE ARM THAT TESTS RATHER THAN AGREES.
//   * TWO DIFFERENT file-scope wildcard items: is the doubling PER ITEM
//     (Q,Q,M,M) or PER PASS (Q,M,Q,M)?
//   * a module whose BODY imports a THIRD package: which group leads?
//   * a PACKAGE declared in a file that carries a file-scope import: does the
//     package materialize the import too, and at what multiplicity?
//   * a module with its OWN parameter, to place the own-params group.
import quarryPkg::*;
import masonPkg::*;
package gLocalPkg;
  parameter int G_LOCAL = 33;
endpackage
module gOrder;
  import gLocalPkg::*;
  parameter int G_OWN = 44;
  int r;
  initial r = quarryTake(7) + masonTake(8) + G_LOCAL + G_OWN;
endmodule
