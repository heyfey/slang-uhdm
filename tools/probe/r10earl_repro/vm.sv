// vm.sv — pass 11, ranked residue (2): `package prim_cipher_pkg {top=1} vs
// {top=0}`.  r10earl11p (the new who-links-this-package probe) says the link is
// the FORMAL typespec of a PACKAGE FUNCTION, stamped on a call argument:
//   ref_obj 'lfsr_state' aes_prng.sv:61:51
//     -> ref_typespec -> logic_typespec prim_cipher_pkg.sv:336:47
//        -> Instance = prim_cipher_pkg   (golden top=1, ours top=0)
// vm reproduces exactly that: a package function taking a vector formal, called
// from a module cont-assign with a net actual, plus the qualified/bare spelling
// pair and a module-local control.
package vmp;
  parameter logic [7:0] TBL = 8'h9;
  function automatic logic [7:0] fx(logic [7:0] a);
    logic [7:0] r;
    r = a ^ 8'h5a;
    return r;
  endfunction
  function automatic logic [7:0] fy(logic [7:0] a, logic [7:0] t);
    logic [7:0] r;
    r = a ^ t;
    return r;
  endfunction
endpackage

module vma (
  input  logic [7:0] p_i,
  output logic [7:0] o_a, o_b, o_c
);
  import vmp::*;
  logic [7:0] mid;

  function automatic logic [7:0] loc(logic [7:0] a);
    return a ^ 8'h11;
  endfunction

  assign mid = p_i ^ 8'h22;
  assign o_a = vmp::fx(mid);   // A  qualified call, net actual
  assign o_b = fx(mid);        // B  bare (wildcard-imported) call
  assign o_c = loc(mid);       // C  module-local function control
endmodule

// vmb — the aes_prng spelling exactly: NO import anywhere in the module, a
// fully qualified call, and a PACKAGE PARAMETER as the second actual.
module vmb (
  input  logic [7:0] p_i,
  output logic [7:0] o_d
);
  logic [7:0] mid2;
  assign mid2 = p_i ^ 8'h33;
  assign o_d = vmp::fy(mid2, vmp::TBL);
endmodule

module vmtop;
  logic [7:0] p, a, b, c, d;
  vma u (.p_i(p), .o_a(a), .o_b(b), .o_c(c));
  vmb v (.p_i(p), .o_d(d));
endmodule
