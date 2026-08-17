// r10uvm85 arm a4 — INDEXED members and DEEPER chains.  Both keep the
// paConstant_bit_select arm in STATEMENT position (an index puts its
// Constant_expression INSIDE the Constant_bit_select rather than swapping the
// node type, which is what makes statement position differ from expression
// position), so the shape must not change with either.
module g85a4;
  class inner4;
    int      arr[$];
    int      aa[string];
    function void um4(int a); endfunction
  endclass
  class c4;
    inner4   h;
    inner4   hv[4];
    int      qq[4][$];
    int      n;
    function void f(int k);
      this.h.arr.delete(0);      // L18 3-deep builtin
      this.h.arr.push_back(k);   // L19
      this.h.aa.delete("k");     // L20
      this.h.um4(k);             // L21 3-deep? no: 2-deep USER control
      this.hv[1].um4(k);         // L22 INDEXED member, user method
      this.hv[k].um4(3);         // L23 INDEXED (variable) member
      this.qq[1].delete(0);      // L24 INDEXED member, BUILTIN
      this.qq[k].push_back(3);   // L25
      this.hv[1].arr.delete(0);  // L26 INDEXED then deeper
    endfunction
  endclass
endmodule
