// r10uvm155 grid, arm D — THE GATE arm.  The SHADOW question asked from every
// home that has a DIFFERENT `component` in Surelog (an out-of-body method is
// compiled in the PACKAGE, an in-body one in the CLASS), plus a typedef in a
// GENERATE block and one used from a DEEPER nesting.  MEASUREMENT ONLY.
package Ledger155;
  typedef bit [2:0] ledgerTally;              // package-level name

  class Abacus155;
    typedef bit [3:0] abacusBead;             // class-level name
    extern function void reckon();
    extern function void tallyOob();

    function void countInBody();
      typedef bit [4:0] abacusBead;           // shadows the CLASS name, in-body
      typedef bit [5:0] ledgerTally;          // shadows the PACKAGE name, in-body
      typedef bit [6:0] slateFresh;           // shadows nothing
      abacusBead  ibBeadShadow;
      ledgerTally ibTallyShadow;
      slateFresh  ibFresh;
      ibBeadShadow = 0; ibTallyShadow = 0; ibFresh = 0;
    endfunction
  endclass

  // OUT-OF-BODY: Surelog compiles this in the PACKAGE, so the CLASS name is
  // NOT in `component->getDataType`'s chain and the PACKAGE name is.
  function void Abacus155::reckon();
    typedef bit [7:0] abacusBead;             // shadows the CLASS name, OOB
    typedef bit [8:0] ledgerTally;            // shadows the PACKAGE name, OOB
    abacusBead  oobBeadShadow;
    ledgerTally oobTallyShadow;
    oobBeadShadow = 0; oobTallyShadow = 0;
  endfunction

  // OUT-OF-BODY with NO local typedef at all: the bare CLASS name from the
  // package's chain.  The control for the line above.
  function void Abacus155::tallyOob();
    abacusBead  oobBeadPlain;
    ledgerTally oobTallyPlain;
    oobBeadPlain = 0; oobTallyPlain = 0;
  endfunction
endpackage

typedef bit [1:0] unitLedger;                 // a $unit name

module Counter155;
  typedef bit [9:0] counterCarry;             // a module name

  function void addUp();
    typedef bit [10:0] counterCarry;          // shadows the MODULE name
    typedef bit [11:0] unitLedger;            // shadows the $unit name
    typedef bit [12:0] tokenFresh;            // shadows nothing
    counterCarry modCarryShadow;
    unitLedger   modUnitShadow;
    tokenFresh   modFresh;
    modCarryShadow = 0; modUnitShadow = 0; modFresh = 0;
  endfunction

  // A typedef declared DIRECTLY in a GENERATE block (not inside a statement
  // scope) and used by a declaration in the same generate block.
  if (1) begin : mint
    typedef bit [13:0] mintStamp;
    mintStamp mintVal;
    initial mintVal = 0;
  end

  // A statement-scope typedef used from a DEEPER nesting, three levels down.
  initial begin
    typedef bit [14:0] vaultDepth;
    begin
      begin
        vaultDepth vaultVal;
        vaultVal = 0;
      end
    end
  end

  initial addUp();
endmodule
