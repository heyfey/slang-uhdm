package pk4;
  int parr[4];
  int pidx[4];
endpackage

class item; int f; endclass
class sub;  int idx[4]; endclass
class base_c;
  int bidx[4];
endclass

class deep extends base_c;
  item  iarr[4];
  int   midx[4];
  sub   s;
  sub   s2[4];
  static int stat[4];
  int   j;
  function int probe();
    int i; int r;
    r = iarr[this.midx[i]].f;        // h1 this.-qualified select index
    r = iarr[pk4::pidx[i]].f;        // h2 package-qualified select index
    r = iarr[deep::stat[i]].f;       // h3 class-static-qualified select index
    r = iarr[bidx[i]].f;             // h4 inherited member select index
    r = iarr[s.idx[i]].f;            // h5 member-chain (control)
    r = iarr[s2[j].idx[i]].f;        // h6 select-then-member-then-select
    r = iarr[midx[midx[midx[i]]]].f; // h7 depth-4
    return r;
  endfunction
endclass
