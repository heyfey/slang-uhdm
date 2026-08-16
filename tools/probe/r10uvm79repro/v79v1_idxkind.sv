package pk1;
  localparam int PP = 2;
endpackage

class item; int f; int g; endclass
class holder; item arr[4]; int idx[4]; endclass

class lat;
  item   iarr[4];
  item   iarr2[4][4];
  item   iq[$];
  item   idyn[];
  item   iai[int];
  int    midx[4];
  int    j, k;
  logic [7:0] pk;
  holder h;
  function int fn(int x); return x; endfunction

  function int probe();
    int i; int r;
    r = iarr[midx[i]].f;              // e1  bit-in-bit
    r = iarr[midx[midx[i]]].f;        // e2  depth-3
    r = iarr[pk[3:0]].f;              // e3  part-in-bit
    r = iarr[pk[i +: 2]].f;           // e4  indexed-up
    r = iarr[pk[i -: 2]].f;           // e5  indexed-down
    r = iarr[i ? j : k].f;            // e6  ternary
    r = iarr[fn(i)].f;                // e7  call
    r = iarr[h.idx[i]].f;             // e8  member-chain
    r = iarr[$clog2(4)].f;            // e9  system call
    r = iarr[{1'b0,1'b1}].f;          // e10 concat
    r = iarr[int'(i)].f;              // e11 cast
    r = iarr[pk1::PP].f;              // e12 pkg param
    r = iarr[midx[i] + 1].f;          // e13 op containing select
    r = iarr[-midx[i]].f;             // e14 unary containing select
    r = iarr[midx[fn(i)]].f;          // e15 bit-select whose index is a call
    r = iarr[midx[pk[1:0]]].f;        // e16 bit-select whose index is a partsel
    return r;
  endfunction
endclass
