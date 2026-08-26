// r10uvm157 grid, arm A — THE SCOPE AXIS.  ONE shape (a typedef declared in a
// statement scope, with a local that uses it) placed in every scope kind the
// brief names, so the question "WHICH UHDM scope carries the listing" is
// answered per kind and not extrapolated from one.  MEASUREMENT ONLY.
// Every typedef name is unique in the design (r10uvm155's repair gate), every
// home gets its own root word, its own case convention and its own width, so
// no cell can agree with another by accident.
package Aviary157;
  typedef int unsigned tallyPkg157;        // NEGATIVE control: a package typedef

  class Roost157;
    typedef bit [2:0] RoostMember157;      // NEGATIVE control: a class typedef
    extern function void burrow();

    // scope 1: an IN-BODY class method's BODY TOP LEVEL
    function void perch();
      typedef bit [3:0] perch_nib_t;
      perch_nib_t perchVal;
      perchVal = 0;
    endfunction

    // scope 2: a BEGIN inside an in-body class method
    function void preen();
      begin
        typedef bit [4:0] PREEN_FIVE;
        PREEN_FIVE preenVal;
        preenVal = 0;
      end
    endfunction

    // scope 3: a class TASK body
    task groom();
      typedef bit [5:0] groomSix157;
      groomSix157 groomVal;
      groomVal = 0;
    endtask
  endclass

  // scope 4: an OUT-OF-BODY class method body, and a NESTED begin inside it
  function void Roost157::burrow();
    typedef bit [6:0] burrowSeven_T;
    burrowSeven_T burrowVal;
    begin
      typedef bit [7:0] BurrowDeep8;
      BurrowDeep8 burrowDeepVal;
      burrowDeepVal = 0;
    end
    burrowVal = 0;
  endfunction

  // scope 5: a PACKAGE FREE function body
  function void flock();
    typedef bit [8:0] flock_kind9;
    flock_kind9 flockVal;
    flockVal = 0;
  endfunction

  // scope 6: a PACKAGE FREE task body with EXACTLY ONE statement after the
  // declarations (Surelog's "0 or 1 Stmt" arm passes the TASK itself as pstmt,
  // not a synthesised begin — CompileStmt.cpp:2115).
  task lone();
    typedef bit [9:0] LoneTen157;
    LoneTen157 loneVal;
    loneVal = 0;
  endtask
endpackage

module Meadow157;
  int drift;

  // scope 7: a module INITIAL body (an UNNAMED begin)
  initial begin
    typedef bit [10:0] grassWord157;
    grassWord157 bladeVal;
    bladeVal = 0;
  end

  // scope 8: a NAMED begin
  initial begin : SunLit157
    typedef bit [11:0] sunlit_twelve;
    sunlit_twelve beamVal;
    beamVal = 0;
  end

  // scope 9: a NESTED begin (two deep), plus scopes 10-13 inside one initial
  initial begin
    int outerDrift;
    begin
      typedef bit [12:0] NESTED_13;
      NESTED_13 coreVal;
      coreVal = 0;
    end
    fork
      // scope 10: a FORK arm
      begin
        typedef bit [13:0] emberWord157;
        emberWord157 sparkVal;
        sparkVal = 0;
      end
    join_none
    // scope 11: a FOR body
    for (int cadence = 0; cadence < 2; cadence++) begin
      typedef bit [14:0] cadenceKind15;
      cadenceKind15 tickVal;
      tickVal = 0;
    end
    // scope 12: an IF arm
    if (outerDrift == 0) begin
      typedef bit [15:0] IfArm_16;
      IfArm_16 pickVal;
      pickVal = 0;
    end
    // scope 13: a CASE item
    case (outerDrift)
      0: begin
        typedef bit [16:0] caseSlot17;
        caseSlot17 slotVal;
        slotVal = 0;
      end
      default: ;
    endcase
  end

  // scope 14: a MODULE FUNCTION body
  function void knead();
    typedef bit [17:0] knead_dough18;
    knead_dough18 lumpVal;
    lumpVal = 0;
  endfunction

  // scope 15: a MODULE TASK body
  task churn();
    typedef bit [18:0] CHURN_BUTTER;
    CHURN_BUTTER patVal;
    patVal = 0;
  endtask

  // scope 16: a NAMED always_comb block
  always_comb begin : Whisk157
    typedef bit [19:0] whiskTwenty157;
    whiskTwenty157 stirVal;
    stirVal = 0;
  end

  // scope 17: a GENERATE block's own initial begin
  if (1) begin : Hedge157
    initial begin
      typedef bit [20:0] hedgeShade21;
      hedgeShade21 hedgeVal;
      hedgeVal = 0;
    end
  end
endmodule

// scope 18/19: a PROGRAM's initial (r10uvm155's carve-out: golden RESOLVES the
// declaration there) and a PROGRAM's task body (golden degrades it).  The
// LISTING question is asked separately from the declaration-kind question.
program Orchard157;
  initial begin
    typedef bit [21:0] fruitPip22;
    fruitPip22 pipVal;
    pipVal = 0;
  end
  task prune();
    typedef bit [22:0] PRUNE_BRANCH;
    PRUNE_BRANCH limbVal;
    limbVal = 0;
  endtask
endprogram
