// r10v109repro/v109_b5.sv - ADVERSARIAL: interaction with the OTHER users of
// the same hoisted-net pool - a `with`-iterator name (law 75), a class-scope
// ENUM CONSTANT (law 76) and a `ref` local (law 107) - each written NEXT TO a
// `= new` lvalue of the SAME class, plus the IN-BODY controls.  MEASUREMENT ONLY.
package pkb5;

  class Pod5;
    int r;
    function new(int a = 0); r = a; endfunction
  endclass

  class Mix5;
    typedef enum {E_ALPHA5, E_BETA5} mode5_e;
    Pod5   enumNewKapa;
    int    listBag5[$];
    int    iterOmega;        // a `with`-iterator NAME (law 75)
    mode5_e modeSel5;
    Pod5   refNewSigma;      // `= new` next to a ref local (law 107)
    int    plainCtl5;        // control
    extern function int  b5with(int iterOmega);
    extern function void b5ref(ref int rl5);
    extern function void b5enum();
    // IN-BODY control: the identical `= new` shape written inside the body.
    function void b5inbody(); enumNewKapa = new(1); endfunction
  endclass

  function int Mix5::b5with(int iterOmega);
    int f5[$];
    enumNewKapa = new(2);                        // G1 `= new`, must be fenced
    f5 = listBag5.find with (item == iterOmega); // G2 law-75 iterator, must KEEP
    return f5.size();
  endfunction

  function void Mix5::b5ref(ref int rl5);
    refNewSigma = new(3);                        // G3 `= new`, must be fenced
    rl5 = rl5 + plainCtl5;                       // G4 plain read, must KEEP
  endfunction

  function void Mix5::b5enum();
    if (modeSel5 == E_ALPHA5)                    // G5 law-76 enum const, must KEEP
      plainCtl5 = 1;
    else if (modeSel5 == Mix5::E_BETA5)          // G6 ScopedName enum const
      plainCtl5 = 2;
  endfunction

endpackage

import pkb5::*;

module topb5;
  Mix5 m5;
  int  s5, x5;
  initial begin
    m5 = new();
    s5 = m5.b5with(3);
    m5.b5ref(x5);
    m5.b5enum();
    m5.b5inbody();
  end
endmodule
