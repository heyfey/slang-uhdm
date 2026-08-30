// r10v166 ARM F -- homes the two SITES can reach that no other arm exercises:
// a class in the COMPILATION UNIT ($unit), an INTERFACE CLASS's implementor,
// a CONSTRUCTOR body, a class typedef whose base is a VIRTUAL INTERFACE, and
// a class typedef named bare inside a randomize/constraint-carrying class.
interface vi166_if;
  logic clk;
endinterface

class Unit166;                         // a class in the COMPILATION UNIT
  typedef int      uKw166_t  [$];      // KEYWORD base   -> declines
  typedef Unit166  uNm166_t  [$];      // NAME base      -> fires
  typedef virtual vi166_if uVif166_t [$];  // VIRTUAL-IF base (declines)

  function new();                      // the CONSTRUCTOR body
    uNm166_t cq166;
    uKw166_t ck166;
    if (cq166.size() + ck166.size() > 0) $display("x");
  endfunction

  function int uUse166();
    uNm166_t  uq166;
    uVif166_t vq166;
    uKw166_t  kq166;
    return uq166.size() + vq166.size() + kq166.size();
  endfunction
endclass

package if166_pkg;
  class Item166;
    int t;
  endclass

  interface class IFace166;
    pure virtual function int ifsize166();
  endclass

  class Impl166 implements IFace166;
    typedef Item166 iq166_t [$];
    virtual function int ifsize166();
      iq166_t iv166;                   // in an INTERFACE-CLASS implementor
      return iv166.size();
    endfunction
  endclass

  class Rnd166;
    typedef Item166 rq166_t [$];
    rand int a166;
    constraint c166 { a166 > 0; }
    function int rUse166();
      rq166_t rv166;
      return rv166.size() + a166;
    endfunction
  endclass
endpackage

module vf166_top;
  import if166_pkg::*;
  vi166_if u_if166 ();
  Unit166  u166;
  Impl166  i166;
  Rnd166   r166;
  int n166;
  initial begin
    u166 = new(); i166 = new(); r166 = new();
    n166 = u166.uUse166() + i166.ifsize166() + r166.rUse166();
  end
endmodule
