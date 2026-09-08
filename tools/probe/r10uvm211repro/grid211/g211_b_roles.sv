// r10uvm211 arm B — EVERY DECLARATION ROLE through an ARRAY of a package
// STRUCT typedef, in one clone body: a FORMAL, a subroutine local, a BLOCK
// local, a for-body local and a class-method local, EACH WITH ITS OWN
// `foreach` so the array object is shared with the HOME listing exactly as the
// corpus's is.  The law must move every clone-exclusive one and no other.
package p211a_b;
  typedef bit [31:0] bt211b;
  typedef struct { bt211b b_addr211; int b_n211; } sb211;

  function automatic int f_formal211(sb211 fa211[]);
    int t211b;
    foreach (fa211[i211b]) t211b = t211b + int'(fa211[i211b].b_addr211);
    return t211b;
  endfunction

  function automatic int f_local211();
    sb211 loc211[$];
    int acc211b;
    foreach (loc211[i211b]) acc211b = acc211b + int'(loc211[i211b].b_addr211);
    begin : blk211
      sb211 blkloc211[];
      foreach (blkloc211[j211b])
        acc211b = acc211b + int'(blkloc211[j211b].b_addr211);
    end
    for (int k211b = 0; k211b < 2; k211b++) begin
      sb211 forloc211[$];
      foreach (forloc211[m211b])
        acc211b = acc211b + int'(forloc211[m211b].b_addr211);
    end
    return acc211b;
  endfunction

  class C211b;
    extern function int m211b();
  endclass
  function int C211b::m211b();
    sb211 mloc211[$];
    int v211b;
    foreach (mloc211[n211b]) v211b = v211b + int'(mloc211[n211b].b_addr211);
    return v211b;
  endfunction
endpackage

package p211b_b;
  import p211a_b::*;
  function automatic int gb211b();
    sb211 arg211[];
    C211b c211b;
    c211b = new();
    return f_formal211(arg211) + f_local211() + c211b.m211b();
  endfunction
endpackage

module g211_b_roles;
  import p211b_b::*;
  int r211b;
  initial r211b = gb211b();
endmodule
