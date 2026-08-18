// v97_c4 — the SPEC-PARAM half.  `copyClassTdSpecParams1` copies the BASE's
// Parameters/Param_assigns onto a clone, and `class_typespec::Compare` READS
// both.  A duplicate that the patch drops therefore also loses those.  The
// base here is a FOREIGN-specialized target so the copy is non-empty.
package p97c4;
  class tgt97c4 #(type T = int);
    T q;
  endclass
  class aaa97c4;                              // base member, writes #(byte)
    typedef tgt97c4 #(byte) nn97c4;
    nn97c4 h_a;
  endclass
  class zzz97c4 #(type U = int);              // clone member, two specs
    typedef tgt97c4 #(byte) nn97c4;
    nn97c4 h_z;
    U v;
  endclass
  class si97c4 extends zzz97c4 #(int);
    function void f(nn97c4 p); h_z = p; endfunction
  endclass
  class sb97c4 extends zzz97c4 #(shortint);
    function void f(nn97c4 p); h_z = p; endfunction
  endclass
endpackage
module top97c4;
endmodule
