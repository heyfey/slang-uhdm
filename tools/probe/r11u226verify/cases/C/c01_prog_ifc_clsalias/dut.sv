// § classTdAliasLastWriter214 — the aliased class specialization typedef imported by an interface and a module named against declaration order
package p;
  class box #(type T = int); T v; endclass
  typedef box #(shortint) sbox_t;
  typedef box #(shortint) sbox2_t;
endpackage
interface zz_i;
  import p::*;
  sbox2_t hz;
endinterface
module aa_m;
  import p::*;
  sbox2_t ha;
endmodule
module top;
  zz_i u_i();
  aa_m u_m();
endmodule
