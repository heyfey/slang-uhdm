// r10uvm81 VERIFIER arm H — LAW 2's LVALUE-BASE and QUALIFIED-BASE joints, the
// two the brief names that arm E only touches obliquely: a nested index under an
// lvalue whose BASE is itself a select / a hierarchical path / a package-scoped
// name, and the module twin of each.
package ph98;
  int parr [8];
  int pidx [8];
endpackage

class inner98; int f; int g[4]; endclass
class mid98;   inner98 arr[4]; int mi[8]; endclass

class outer98;
  mid98  m[4];
  int    idx[8];
  int    i;
  int    flat[8];
  bit [31:0] bw [4];
  function int fn98(int a); return a; endfunction
  function int probe98();
    int r;
    // LVALUE bases of increasing depth
    m[idx[idx[i]]].arr[idx[i]].f = 1;              // h1 two-level lvalue base
    m[idx[i]].arr[idx[idx[i]]].f = 2;              // h2 nested idx on the 2nd step
    m[idx[idx[i]]].mi[idx[idx[i]]] = 3;            // h3 nested idx on BOTH steps
    flat[idx[idx[idx[i]]]] = 4;                    // h4 depth-3 lvalue
    ph98::parr[ph98::pidx[idx[i]]] = 5;            // h5 pkg-qualified lvalue base
    this.flat[idx[idx[i]]] = 6;                    // h6 this-qualified lvalue
    bw[idx[idx[i]]][7:0] = 8'h2;                   // h7 part-select lvalue
    // the same as RVALUES
    r = m[idx[idx[i]]].arr[idx[i]].f;              // h8
    r = ph98::parr[ph98::pidx[idx[i]]];            // h9
    r = fn98(m[idx[idx[i]]].arr[idx[i]].f);        // h10 as a call argument
    return r;
  endfunction
endclass

module mh98;
  typedef struct { int f; } sf98;
  typedef struct { sf98 arr[4]; int mi[8]; } sm98;
  sm98 m[4];
  int  idx[8];
  int  z;
  int  flat[8];
  bit [31:0] bw [4];
  function int mfn98(int a); return a; endfunction
  initial begin
    m[idx[idx[z]]].arr[idx[z]].f = 1;              // k1
    m[idx[z]].arr[idx[idx[z]]].f = 2;              // k2
    m[idx[idx[z]]].mi[idx[idx[z]]] = 3;            // k3
    flat[idx[idx[idx[z]]]] = 4;                    // k4
    ph98::parr[ph98::pidx[idx[z]]] = 5;            // k5
    bw[idx[idx[z]]][7:0] = 8'h2;                   // k7
    z = m[idx[idx[z]]].arr[idx[z]].f;              // k8
    z = mfn98(m[idx[idx[z]]].arr[idx[z]].f);       // k10
  end
endmodule
