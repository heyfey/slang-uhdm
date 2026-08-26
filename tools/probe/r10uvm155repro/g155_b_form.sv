// r10uvm155 grid, arm B — THE DECLARED-TYPE FORM axis.  Every form a
// STATEMENT-SCOPE typedef can take, against the same forms declared at
// package / class / $unit level as NEGATIVE controls.  MEASUREMENT ONLY.
typedef bit [1:0] unitLevelSpan;                 // NEGATIVE: a $unit typedef

package Quarry155;
  typedef bit [2:0] quarryVector;                // NEGATIVE: package, vector
  typedef enum { QUARRY_LOW, QUARRY_HIGH } quarryMood;   // NEGATIVE: package enum
  typedef struct packed { bit [3:0] grain; } quarryGrain; // NEGATIVE: package struct
  typedef quarryVector quarryChain;              // NEGATIVE: package td-of-td

  class Chisel155;
    typedef bit [4:0] chiselEdge;                // NEGATIVE: class typedef
  endclass

  class Mallet155 #(type MalletHead = int, int MalletSize = 3);
    typedef bit [MalletSize:0] malletBand;
    function void strike();
      // POSITIVE forms, all declared INSIDE the function body
      typedef bit [5:0]                          formVector;
      typedef logic [6:0]                        formLogic;
      typedef int                                formInt;
      typedef string                             formString;
      typedef enum { GRIT_A, GRIT_B }            formEnum;
      typedef struct packed { bit [7:0] shard; } formStruct;
      typedef formVector                         formChain;      // td of a local td
      typedef Chisel155                          formClassAlias; // alias of a class
      typedef MalletHead                         formTypeParam;  // alias of a type param
      typedef quarryVector                       formPkgAlias;   // alias of a PACKAGE td
      typedef bit [7:0]                          quarryVector;   // SHADOWS a package td

      formVector      vVector;
      formLogic       vLogic;
      formInt         vInt;
      formString      vString;
      formEnum        vEnum;
      formStruct      vStruct;
      formChain       vChain;
      formClassAlias  vClassAlias;
      formTypeParam   vTypeParam;
      formPkgAlias    vPkgAlias;
      quarryVector    vShadow;      // the LOCAL one shadows; does the name repair?

      // NEGATIVE controls in the SAME block
      quarryMood      vPkgEnumCtl;
      quarryGrain     vPkgStructCtl;
      quarryChain     vPkgChainCtl;
      Chisel155       vClassCtl;
      malletBand      vClassBandCtl;
      MalletHead      vTypeParamCtl;
      Mallet155#(int) vParamClassCtl;

      vVector = 0; vLogic = 0; vInt = 0; vString = ""; vEnum = GRIT_A;
      vStruct.shard = 0; vChain = 0; vClassAlias = null; vTypeParam = 0;
      vPkgAlias = 0; vShadow = 0; vPkgEnumCtl = QUARRY_LOW;
      vPkgStructCtl.grain = 0; vPkgChainCtl = 0; vClassCtl = null;
      vClassBandCtl = 0; vTypeParamCtl = 0; vParamClassCtl = null;
    endfunction
  endclass

  function void quarrySeam();
    Mallet155#(int, 3) seamHandle = new();
    seamHandle.strike();
  endfunction
endpackage

// The `$unit` control lives in a MODULE: a package may not reference a
// compilation-unit item (slang refuses it, LRM 3.12.1), so the only place this
// NEGATIVE control can be measured is a module subroutine.
module Adit155;
  function void shaft();
    typedef bit [8:0] shaftLocalSpan;    // POSITIVE: statement-scope typedef
    unitLevelSpan  vUnitCtl;             // NEGATIVE: the $unit typedef
    shaftLocalSpan vShaftLocal;
    vUnitCtl = 0; vShaftLocal = 0;
  endfunction
  initial shaft();
endmodule
