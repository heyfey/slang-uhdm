// r10v130repro/v130_b6.sv — VERIFIER ARM b6: the DECLARATION-KIND grid,
// extended past uvm130's a3 — a CONST local, a function LOCALPARAM, an AUTOMATIC
// local, a STATIC local, a foreach ITERATOR, a `with` ITERATOR, an OUTPUT
// formal, an INOUT formal, a formal WITH A DEFAULT, and a name declared in an
// ENCLOSING named block one level out.  MEASUREMENT ONLY.
// LHS is ALWAYS golden; RHS is ALWAYS ours.
package pkDecl130v;
  class cDecl130v;
    int dynDecl130v[];
    int srcDecl130v[];
    extern function void declRunner130v(output int outFormalAlp130v,
                                        inout  int inoutFormalBet130v);
    extern function void defFormalRunner130v(int defFormalGam130v = 3);
  endclass

  function void cDecl130v::declRunner130v(output int outFormalAlp130v,
                                          inout  int inoutFormalBet130v);
    const int constLocalDel130v = 2;
    localparam int lparamLocalEps130v = 3;
    automatic int autoLocalZet130v = 4;
    static int staticLocalEta130v = 5;
    outFormalAlp130v = 1;
    srcDecl130v = new[2];
    dynDecl130v = new[constLocalDel130v];        // d01 CONST local
    dynDecl130v = new[lparamLocalEps130v];       // d02 function LOCALPARAM
    dynDecl130v = new[autoLocalZet130v];         // d03 AUTOMATIC local
    dynDecl130v = new[staticLocalEta130v];       // d04 STATIC local
    dynDecl130v = new[outFormalAlp130v];         // d05 OUTPUT formal
    dynDecl130v = new[inoutFormalBet130v];       // d06 INOUT formal
    begin : outerBlk130v
      int outerBlkThe130v;
      outerBlkThe130v = 6;
      begin : innerBlk130v
        dynDecl130v = new[outerBlkThe130v];      // d07 ENCLOSING named-block local
      end
    end
    foreach (srcDecl130v[feIterIot130v])
      dynDecl130v = new[feIterIot130v];          // d08 FOREACH iterator
  endfunction

  function void cDecl130v::defFormalRunner130v(int defFormalGam130v = 3);
    dynDecl130v = new[defFormalGam130v];         // d09 formal WITH A DEFAULT
  endfunction
endpackage

import pkDecl130v::*;

module topDecl130v;
  initial begin
    cDecl130v hDecl130v;
    int aOutDecl130v;
    int aInoutDecl130v;
    hDecl130v = new();
    aInoutDecl130v = 7;
    hDecl130v.declRunner130v(aOutDecl130v, aInoutDecl130v);
    hDecl130v.defFormalRunner130v(9);
  end
endmodule
