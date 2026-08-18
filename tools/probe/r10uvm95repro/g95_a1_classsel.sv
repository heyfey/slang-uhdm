// r10uvm95 grid A — $bits(<arg>) rooted at an OWN CLASS PROPERTY, in-block method.
// One call per line; the LINE NUMBER is the cell key.
package pA95;

  typedef struct packed { bit [11:0] hi; bit [3:0] lo; } sp95_t;   // 16
  typedef struct packed { bit [4:0] q; } sq95_t;                   // 5
  typedef enum bit [2:0] { E0, E1 } en95_t;                        // 3
  typedef bit [9:0] tv95_t;                                        // 10

  class holder95;
    byte                b1;
    int                 i1;
    bit [7:0]           v8;
    bit [31:0]          v32;
    sp95_t              st;
    en95_t              en;
    tv95_t              tv;
    byte                arr4  [4];      // fixed unpacked, 4x8 = 32
    bit  [7:0]          pk4   [4];      // 32
    bit  [15:0]         w2    [3];      // 48
    byte                dyn   [];       // dynamic
    byte                que   [$];      // queue
    byte                aso   [string]; // assoc
    sp95_t              sarr  [2];      // 32
    string              str;
    real                rl;
    holder95            hnd;
    int                 md    [2][3];   // 192
    function void go(int i);
      int r;
      r = $bits(b1);
      r = $bits(i1);
      r = $bits(v8);
      r = $bits(v32);
      r = $bits(st);
      r = $bits(en);
      r = $bits(tv);
      r = $bits(arr4);
      r = $bits(arr4[0]);
      r = $bits(arr4[i]);
      r = $bits(pk4);
      r = $bits(pk4[1]);
      r = $bits(pk4[i]);
      r = $bits(pk4[i][3]);
      r = $bits(w2);
      r = $bits(w2[i]);
      r = $bits(w2[i][7:0]);
      r = $bits(dyn);
      r = $bits(dyn[0]);
      r = $bits(dyn[i]);
      r = $bits(que);
      r = $bits(que[i]);
      r = $bits(aso);
      r = $bits(aso["k"]);
      r = $bits(sarr);
      r = $bits(sarr[i]);
      r = $bits(sarr[i].hi);
      r = $bits(st.hi);
      r = $bits(st.lo);
      r = $bits(v32[7:0]);
      r = $bits(v32[3]);
      r = $bits(v32[i]);
      r = $bits(v32[i+:4]);
      r = $bits(str);
      r = $bits(rl);
      r = 0;  // $bits(<class handle>): golden KEEPS, slang REJECTS the call
      r = $bits(md);
      r = $bits(md[i]);
      r = $bits(md[i][1]);
      r = $bits(this.b1);
      r = $bits(this.arr4[i]);
      r = $bits(hnd.b1);
      r = $bits(hnd.arr4[i]);
      if (r > 0) r = 0;
    endfunction
  endclass
endpackage
