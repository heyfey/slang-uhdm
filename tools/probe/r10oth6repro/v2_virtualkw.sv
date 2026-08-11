// r10oth6 arm 2 -- WHERE does golden's class_defn `vpiVirtual:1` come from,
// and the OTHER positions a virtual-interface type can sit in.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
interface w_if(input bit clk);
  logic a;
  modport IP(input clk, output a);
endinterface

// k1 -- CONTROL: a plain class with NO `virtual` anywhere.
class k1_plain;
  int x;
endclass

// k2 -- a VIRTUAL CLASS (the only spelling we currently stamp).
virtual class k2_virtclass;
  int x;
endclass

// k3 -- a plain class with a VIRTUAL METHOD (no virtual interface at all).
class k3_virtmethod;
  int x;
  virtual function int f();
    return x;
  endfunction
endclass

// k4 -- a plain class with a PURE VIRTUAL method (must be abstract).
virtual class k4_purevirt;
  int x;
  pure virtual function int f();
endclass

// k5 -- CONTROL: plain class whose only `virtual` is a virtual-interface
//       LOCAL VARIABLE inside a method body.
class k5_localvif;
  int x;
  function void f();
    virtual w_if.IP  lv;
    lv = null;
  endfunction
endclass

// k6 -- a virtual interface property reached through a TYPEDEF.
typedef virtual w_if.IP  wif_t;
class k6_typedef;
  wif_t  vi;
  int    after;
endclass

// k7 -- a virtual-interface TASK argument (not a function argument).
class k7_taskarg;
  int x;
  task t(virtual w_if.IP  vin);
    x = 1;
  endtask
endclass

// k8 -- the SVSwitch shape verbatim: property + ctor arg + `this.` assign.
class k8_svswitch;
  virtual w_if.IP  input_intf;
  int              mbx;
  function new(virtual w_if.IP  input_intf_new, int mbx);
    this.input_intf = input_intf_new;
    this.mbx        = mbx;
  endfunction
endclass

// k9 -- a class in a PACKAGE with a virtual interface property.
package k9_pkg;
  class k9_cls;
    virtual w_if.IP  vi;
    int              after;
  endclass
endpackage

// k10 -- an INTERFACE CLASS whose methods are `pure virtual` WITHOUT the
//        class itself being declared `virtual`: the only spelling that can
//        tell `pure_virtual_qualifier` apart from `virtual class`.
interface class k10_ifclass;
  pure virtual function int f();
endclass

// k11 -- a virtual-interface TYPEDEF written INSIDE the class body.
class k11_innertypedef;
  typedef virtual w_if.IP  inner_t;
  int x;
endclass

module top2;
  bit  clk;
  w_if u(clk);
  k1_plain h;
endmodule
