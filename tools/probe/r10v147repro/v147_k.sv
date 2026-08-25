// r10uvm147 VERIFIER grid K — NamedValue symbol kinds the implementer's grids
// never produced, each of which the widened gate now admits.
package q147vk;
  typedef struct { logic [63:0] arr[4]; logic [63:0] pk; } sk147_t;
  parameter  sk147_t QK = '{arr:'{64'h1,64'h2,64'h3,64'h4}, pk:64'h9};  // PARAMETER (not local)

  class ck147 #(int W = 64);
    logic [W-1:0] value[];
    sk147_t       s;
  endclass

  function automatic void kf(ck147#(64) fa, ck147#(32) fb, const ref sk147_t cs,
                             int idx, int i);
    logic [7:0] o;
    static logic [7:0] so;
    o  = QK.arr[idx][8*i +: 8];        // k01 package PARAMETER base
    o  = fa.s.arr[idx][8*i +: 8];      // k02 property struct member, specialization 64
    o  = fb.value[idx][8*i +: 8];      // k03 a DIFFERENT specialization
    o  = cs.arr[idx][8*i +: 8];        // k04 `const ref` STRUCT formal
    so = fa.value[idx][8*i +: 8];      // k05 STATIC local as the target
  endfunction

  class kuser147;
    ck147#(64) h;
    sk147_t    sp;
    function void g(int idx, int i);
      logic [7:0] o;
      o = sp.arr[idx][8*i +: 8];       // k06 struct-typed CLASS PROPERTY base
      o = h.s.arr[idx][8*i +: 8];      // k07 handle property -> struct member
    endfunction
  endclass
endpackage

module m147k;
  import q147vk::*;
  sk147_t mv;
  int idx, i;
  logic [7:0] o;
  initial begin
    fork
      begin
        automatic sk147_t av = mv;
        o = av.arr[idx][8*i +: 8];     // k08 AUTOMATIC var inside a fork
      end
    join_none
  end
  initial o = QK.arr[idx][8*i +: 8];   // k09 imported package PARAMETER base
  initial o = mv.arr[idx][8*i +: 8];   // k10 module Variable control
endmodule
