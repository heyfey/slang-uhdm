// r10uvm147 VERIFIER grid I — the ITERATOR symbol kind (`item` inside a
// `with` clause).  Isolated in its own file so a tool rejection cannot poison
// the other grids.
package q147vi;
  typedef struct { logic [63:0] arr[4]; } si147_t;
  class ci147;
    si147_t q[$];
    si147_t f[4];
    int     r;
    function void g(int idx, int i);
      si147_t lv;
      logic [7:0] o;
      r = q.sum with (int'(item.arr[idx][8*i +: 8]));   // i01 ITERATOR base
      r = f.sum with (int'(item.arr[idx][8*i +: 8]));   // i02 ITERATOR base, fixed
      o = lv.arr[idx][8*i +: 8];                        // i03 local control
    endfunction
  endclass
endpackage
