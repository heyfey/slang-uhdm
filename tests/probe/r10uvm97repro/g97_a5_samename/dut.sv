// r10uvm97 arm a5 — THE DEDUP-KEY REFUTATION.  MEASUREMENT-ONLY golden arm.
//
// TWO DIFFERENT classes that share a NAME across two modules, each with a
// typedef that shares a NAME, both targeting the same class.  Surelog registers
// them under DIFFERENT design-map keys and golden gives them a real group
// (base + aliased clone).  A pass-97 dedup keyed on the STRING
// `surelogClassKey54(cls) + "::" + name` would collapse them (both spell
// `work@dup97e`) and DROP an alias golden has — which is why the dedup is keyed
// on the DECLARING GENERIC CLASS POINTER instead.
class tgt97e;
  int v;
endclass

module m1_97e;
  class dup97e;
    typedef tgt97e n97e;
    n97e h;
  endclass
  dup97e d;
  initial d = new();
endmodule

module m2_97e;
  class dup97e;
    typedef tgt97e n97e;
    n97e h;
  endclass
  dup97e d;
  initial d = new();
endmodule

module top97e;
  m1_97e i1();
  m2_97e i2();
endmodule
