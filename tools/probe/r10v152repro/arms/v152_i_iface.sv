// r10v152 arm I — INTERFACE-CLASS and ABSTRACT-CLASS handles as the eaten
// element, plus a forward-declared class handle, in an out-of-body constructor.
package ifcpkg;
  interface class Talky;
    pure virtual function void speak();
  endclass
  virtual class Abstracty;
    pure virtual function int val();
  endclass
  typedef class Later2;
  class Later2 implements Talky;
    virtual function void speak(); endfunction
  endclass

  class HostA;
    int az;
    extern function new();
  endclass
  function HostA::new();
    Talky t_first;               // i01 EATEN, INTERFACE-CLASS handle
    Abstracty a_second;          // i02 abstract class handle
    Later2 l_third;              // i03 forward-declared class handle
    t_first  = null;
    a_second = null;
    l_third  = null;
    az = 1;
  endfunction

  class HostB;
    int bz;
    extern function new();
  endclass
  function HostB::new();
    Abstracty ab_first;          // i04 EATEN, abstract class handle
    Talky     tk_second;         // i05
    ab_first  = null;
    tk_second = null;
    bz = 2;
  endfunction
endpackage

module mifc;
  import ifcpkg::*;
  HostA ha; HostB hb;
  initial begin ha = new(); hb = new(); end
endmodule
