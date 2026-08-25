// r10uvm124 arm A — SELECT KINDS on the receiver of a STATEMENT-position
// built-in method call.  Names deliberately unlike each other and unlike the
// arm letter, so an agreeing cell cannot be an artefact of the naming scheme.
package Kinds124;
  class Bucket;
    int  Depot[$];
    int  ByName[string];
    function void Stow(int Amount); endfunction
  endclass
  class KeyObj;
    int Serial;
  endclass
  class Warehouse;
    Bucket  ByHandle[KeyObj];      // associative, class key
    Bucket  ByLabel[string];       // associative, string key
    Bucket  ByCount[int];          // associative, int key
    Bucket  Elastic[];             // dynamic
    Bucket  Shelf[6];              // fixed unpacked
    Bucket  Pile[$];               // queue
    Bucket  Grid2[3][3];           // two dimensions
    bit [31:0] Word;
    int     PlainQ[$];
    int     PlainA[string];
    task automatic Load(KeyObj Kx, string Lx, int Nx);
      ByHandle[Kx].Depot.push_back(101);
      ByLabel[Lx].Depot.push_back(102);
      ByCount[Nx].Depot.push_back(103);
      Elastic[Nx].Depot.push_back(104);
      Shelf[3].Depot.push_back(105);
      Pile[Nx].Depot.push_back(106);
      Grid2[1][2].Depot.push_back(107);
      Word[7:0] = 8'h5a;                      // part select: NOT a call
      PlainQ.push_back(108);                  // FENCE: no select at all
      PlainA.delete(Lx);                      // FENCE: no select at all
    endtask
  endclass
endpackage
