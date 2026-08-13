// r10buvm2 ARM a2 ??? the OTHER TWO cells the BuildUVMPkg census turned up:
// a `= null` class-handle property and a `= $sysfunc` property.  Same file so a
// single golden run measures both, with the SS virtualIfaceNullInitIsClassParented6
// control (a VIRTUAL-INTERFACE property, whose null is parented at the
// CLASS_DEFN, not the variable) sitting beside them.
interface vif2;
  logic a;
endinterface

package p2;

  class base2;
  endclass

  class c2;
    // --- m01..m03: the NULL axis --------------------------------------------
    base2   m01_null = null;    // uvm_component::m_unsupported_resource_base
    chandle m02_null = null;
    string  m03_ctrl = "x";     // control: an already-modelled literal kind
    // --- m04..m09: the SYSTEM-CALL axis -------------------------------------
    int  m04_urand  = $urandom;               // uvm_default_coreservice_t
    int  m05_urandr = $urandom_range(1, 10);  // ... with ARGUMENTS
    int  m06_random = $random;
    time m07_time   = $time;
    int  m08_bits   = $bits(int);             // a FOLDABLE system call
    real m09_sqrt   = $sqrt(4.0);
    // --- m10: the USER call control (already SS classPropCallInit29) ----------
    static function int uf2(); return 1; endfunction
    int  m10_user   = uf2();
  endclass

endpackage

module m2top;
  // SS virtualIfaceNullInitIsClassParented6's CONTROL: the class-defn-parented
  // null.  If the widened null arm re-parents THIS one it is an over-fire.
  vif2 iv();
endmodule

package p2v;
  class c2v;
    virtual vif2 m11_vnull = null;
  endclass
endpackage
