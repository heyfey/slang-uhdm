// residue (no law landed): goal-1 shape this.mk().inner.s, see README
class I; int s; endclass
class C;
  I inner = new;
  function C mk(); return this; endfunction
  function int f(); return this.mk().inner.s; endfunction
endclass
module top; C c; endmodule
