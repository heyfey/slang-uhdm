// r10uvm147 arm A — the DECODE arm: the corpus shape (a FORMAL-ARGUMENT
// receiver carrying a member, an element select and a trailing indexed part
// select) against its neighbours on the three axes the law names: STEP COUNT,
// TRAILING SELECT KIND, and RECEIVER SYMBOL KIND.
package q147a;

  class inner147;
    logic [31:0] value[];        // dynamic array
    logic [31:0] varr[4];        // fixed unpacked
    logic [31:0] que[$];         // queue
    logic [31:0] p2[2][3];       // 2-dim unpacked
    logic [63:0] pk;             // packed scalar
    logic [3:0][7:0] pk2;        // packed 2-dim
  endclass

  class drv147;
    inner147 mprop;              // a CLASS PROPERTY receiver
    int mi;

    // A1 — the CORPUS CELL: a FORMAL ARGUMENT receiver.
    function void fa(inner147 rw, int idx, int i);
      logic [7:0] o;
      logic [31:0] o32;
      logic [31:0] oa[8];
      o = rw.value[idx][8*i +: 8];   // a01 2 steps, trailing +:
      o = rw.value[idx][8*i -: 8];   // a02 2 steps, trailing -:
      o = rw.value[idx][7:0];        // a03 2 steps, trailing constant range
      o = rw.value[idx][3];          // a04 2 steps, trailing bit-select
      o32 = rw.value[idx];           // a05 1 step,  no trailing select
      oa = rw.value[8*i +: 8];       // a06 range directly on the member
      o = rw.p2[idx][mi][8*i +: 8];  // a07 3 steps, trailing +:
      o = rw.pk[8*i +: 8];           // a08 packed member, range only
      o = rw.pk2[idx][8*i +: 8];     // a09 packed 2-dim, 2 steps
      o = rw.que[idx][8*i +: 8];     // a10 queue receiver
      o = rw.varr[idx][8*i +: 8];    // a11 fixed unpacked receiver
      o = rw.value[idx][idx +: 8];   // a12 bare-ref base
      o = rw.value[idx][3 +: 8];     // a13 literal base
      o = rw.value[mi][8*i +: 8];    // a14 class-property index
      o = rw.value[2][8*i +: 8];     // a15 literal index
    endfunction

    // A2 — a LOCAL VARIABLE receiver (the arm's ORIGINAL population; control).
    function void fb(int idx, int i);
      inner147 lv;
      logic [7:0] o;
      o = lv.value[idx][8*i +: 8];   // b01
      o = lv.value[idx][7:0];        // b02
      o = lv.value[idx][3];          // b03
      o = lv.p2[idx][i][8*i +: 8];   // b04
    endfunction

    // A3 — a CLASS PROPERTY receiver.
    function void fc(int idx, int i);
      logic [7:0] o;
      o = mprop.value[idx][8*i +: 8]; // c01
      o = mprop.value[idx][7:0];      // c02
      o = mprop.value[idx][3];        // c03
      o = mprop.p2[idx][i][8*i +: 8]; // c04
    endfunction

    // A4 — WRITE (lvalue) position, all three receivers.
    function void fd(inner147 rw, int idx, int i);
      inner147 lv;
      rw.value[idx][8*i +: 8] = 8'h1;    // d01 formal, lvalue
      lv.value[idx][8*i +: 8] = 8'h2;    // d02 local,  lvalue
      mprop.value[idx][8*i +: 8] = 8'h3; // d03 property, lvalue
      rw.value[idx][7:0] = 8'h4;         // d04 formal, lvalue, const range
    endfunction
  endclass

  // A5 — a PACKAGE-FREE function with a formal-argument receiver.
  function automatic void f147e(inner147 rw, int idx, int i);
    logic [7:0] o;
    o = rw.value[idx][8*i +: 8];      // e01
    o = rw.value[idx][7:0];           // e02
  endfunction

endpackage

module m147a;
  import q147a::*;
  inner147 mv;                        // a MODULE variable receiver
  int idx, i;
  logic [7:0] o;
  initial begin
    o = mv.value[idx][8*i +: 8];      // f01 module var, in an initial block
    o = mv.value[idx][7:0];           // f02
    o = mv.p2[idx][i][8*i +: 8];      // f03
  end
endmodule
