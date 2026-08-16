// r10uvm78 arm c2 — the INDEXED part-select arm.
//
// The corpus reaches BOTH range-select kinds through the same two joints, and
// the census population is dominated by the INDEXED form:
//   * uvm_packer `m_bits[i +: 8]` inside a class method (SimpleUVM, Scoreboard,
//     SeqDriver, BuildUVMPkg) — R3 only;
//   * aes_pkg `in[8*s +: 8]` inside a PACKAGE FUNCTION (Earlgrey_0_1) — R3
//     only, and the ONLY corpus row outside the UVM family.
//
// i1 is the class-method spelling, i2 the package-function spelling (a
// package function is `::`-scoped without any class in the chain, which is the
// case UHDM's ComputeFullName decides on the PACKAGE ancestor alone), and i3 is
// the module-scope control that must not move.
package p78c2;
  class packer;
    bit m_bits[1024];
    function void chunk(int i);
      bit slice[8];
      slice = m_bits[i*8 +: 8];   // i1: class method, indexed
    endfunction
  endclass

  function automatic bit [31:0] shiftit(bit [31:0] in, int s);
    bit [31:0] o;
    o[0 +: 8] = in[8*s +: 8];     // i2: PACKAGE FUNCTION, indexed, both sides
    return o;
  endfunction
endpackage

module top78c2;
  bit [63:0] v;
  bit [7:0] o8;
  int j;
  initial begin
    j = 2;
    o8 = v[j*8 +: 8];             // i3: module scope — control
  end
endmodule
