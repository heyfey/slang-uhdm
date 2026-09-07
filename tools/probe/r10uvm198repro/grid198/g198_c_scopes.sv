// r10uvm198 arm C — WHICH DECLARING SCOPE.
// A class-scope typedef can be declared in a plain class, in a NESTED class, in
// a PARAMETERIZED class, or in a BASE class an out-of-body method inherits it
// from.  One golden, both views, one clone.
package foundry198;
  class Base198;
    typedef struct { int ingot198; } baseSt198;     // inherited by Derived198
  endclass
  class Nest198;
    class Inner198;
      typedef struct { int core198; } innerSt198;
    endclass
    typedef struct { int shell198; } nestSt198;
    extern function void mould198();
  endclass
  class Param198 #(int W198 = 4);
    typedef struct { bit [W198-1:0] billet198; } paramSt198;
    extern function void press198();
  endclass
  class Derived198 extends Base198;
    extern function void forge198();
  endclass
  function void Nest198::mould198();
    begin
      nestSt198             cNest198;              // declaring class: plain
      Inner198::innerSt198  cInner198;             // NESTED class, scoped spelling
      cNest198.shell198 = 0;
      cInner198.core198 = 0;
    end
  endfunction
  function void Param198::press198();
    begin
      paramSt198 cParam198;                        // PARAMETERIZED class
      cParam198.billet198 = 0;
    end
  endfunction
  function void Derived198::forge198();
    begin
      baseSt198 cBase198;                          // inherited from the BASE class
      cBase198.ingot198 = 0;
    end
  endfunction
endpackage
package anvil198;
  import foundry198::*;
  class Anvil198;
    function void strike198();
      Nest198 n198;
      Derived198 d198;
      n198 = null;
      d198 = null;
    endfunction
  endclass
endpackage
