// r10uvm150 arm C — the ROOT-OF-THE-CHAIN discriminator.
// Every cell writes a DIFFERENT root kind under an identical trailing `.m(...)`.
package Pc3;
  typedef struct packed { logic [7:0] hi; logic [7:0] lo; } W16;

  class Leaf1;
    int z = 5;
    function int mul(int m); return z*m; endfunction
    function Leaf1 self(); return this; endfunction
  endclass

  class Root0;
    extern static function Leaf1 obGet();
    static function Leaf1 ibGet(); Leaf1 t = new(); return t; endfunction
    function Leaf1 instGet(); Leaf1 t = new(); return t; endfunction
  endclass
  function Leaf1 Root0::obGet(); Leaf1 t = new(); return t; endfunction

  class Kid0 extends Root0;
    function Leaf1 instGet(); Leaf1 t = new(); t.z = 8; return t; endfunction
    function int k01(); return super.instGet().mul(2); endfunction   // C-super
    function int k02(); return this.instGet().mul(3);  endfunction   // C-this
    function int k03(); return instGet().mul(4);       endfunction   // C-bare method
  endclass

  class Gen0 #(type T = int, int NN = 1);
    extern static function Leaf1 gGet();
  endclass
  function Leaf1 Gen0::gGet(); Leaf1 t = new(); return t; endfunction

  function Leaf1 pcMake(); Leaf1 t = new(); return t; endfunction
  function W16   pcWord();  W16 w; w = '0; return w; endfunction
endpackage

module TopC;
  import Pc3::*;
  Leaf1 lv;
  int a1,a2,a3,a4,a5,a6,a7;

  // C1  PACKAGE-qualified root call + method
  function int c1f(); return Pc3::pcMake().mul(6); endfunction
  // C2  PACKAGE-qualified root call, NO chain (span control)
  function automatic Leaf1 c2f(); return Pc3::pcMake(); endfunction
  // C3  PARAMETERIZED-class root call + method
  function int c3f(); return Gen0#(int,2)::gGet().mul(7); endfunction
  // C4  in-body static root + method  (ref_obj degrade)
  function int c4f(); return Root0::ibGet().mul(8); endfunction
  // C5  out-of-body static root + method
  function int c5f(); return Root0::obGet().mul(9); endfunction
  // C6  root call returning a STRUCT, trailing MEMBER (not a call)
  function logic [7:0] c6f(); return Pc3::pcWord().hi; endfunction
  // C10 PARAMETERIZED-class root, NO chain — the § classScopeCall…26 control
  //     that tells a pre-existing vpiFunction residue from one this law caused
  function automatic Leaf1 c10f(); return Gen0#(int,2)::gGet(); endfunction
  // C11 out-of-body static root, NO chain (the same control, unspecialized)
  function automatic Leaf1 c11f(); return Root0::obGet(); endfunction
  // C7  plain variable root, one method  (control)
  function int c7f(); return lv.mul(1); endfunction
  // C8  a WHILE body home
  function int c8f(); int s = 0; while (s < 2) begin s = Root0::obGet().mul(1); end return s; endfunction
  // C9  a FOR body home, TWO instances
  function int c9f(); int s = 0; for (int i=0;i<2;i++) s += Root0::obGet().mul(i) + Pc3::pcMake().mul(i); return s; endfunction
  initial begin
    lv = new();
    a1 = c1f(); a2 = c3f(); a3 = c4f(); a4 = c5f();
  end
endmodule
