// r10uvm147 arm D — the SYSTEMATIC cross: STEP COUNT (0/1/2/3) x TRAILING
// SELECT KIND (+: / -: / constant range / bit-select / none) x INDEX SHAPE
// (bound local / formal / literal / expression / nested select / a package
// parameter / a genvar-free localparam), on a FORMAL-ARGUMENT receiver (the
// kind the pristine gate refused) and its LOCAL-VARIABLE twin (the kind it
// already accepted -- the CONTROL that must not move).
package q147d;
  localparam int PD = 2;

  class cd147;
    logic [63:0] d1[];         // 1 unpacked dim
    logic [63:0] d2[3][4];     // 2 unpacked dims
    logic [63:0] d3[2][3][4];  // 3 unpacked dims
    logic [63:0] pk;           // packed only
    int          ix[8];
  endclass

  class dd147;
    function void g(cd147 fa, int lo, int i);
      cd147 lv;
      logic [7:0]  o;
      logic [63:0] o64;
      // ---- STEP COUNT x TRAILING KIND, formal receiver -------------------
      o64 = fa.d1[lo];               // d01 1 step, no trailing
      o64 = fa.d2[lo][i];            // d02 2 steps, no trailing
      o64 = fa.d3[lo][i][PD];        // d03 3 steps, no trailing
      o   = fa.d1[lo][8*i +: 8];     // d04 1 step + up-range
      o   = fa.d2[lo][i][8*i +: 8];  // d05 2 steps + up-range
      o   = fa.d3[lo][i][PD][8*i+:8];// d06 3 steps + up-range
      o   = fa.d1[lo][8*i+7 -: 8];   // d07 1 step + down-range
      o   = fa.d2[lo][i][8*i+7 -: 8];// d08 2 steps + down-range
      o   = fa.d1[lo][15:8];         // d09 1 step + constant range
      o   = fa.d2[lo][i][15:8];      // d10 2 steps + constant range
      o   = fa.d1[lo][3];            // d11 1 step + bit-select
      o   = fa.d2[lo][i][3];         // d12 2 steps + bit-select
      o   = fa.pk[8*i +: 8];         // d13 0 steps + up-range (control)
      o   = fa.pk[15:8];             // d14 0 steps + constant range (control)
      // ---- INDEX SHAPE, formal receiver, always 1 step + up-range --------
      o = fa.d1[lo][8*i +: 8];       // d15 bound LOCAL formal index
      o = fa.d1[i][8*i +: 8];        // d16 another formal
      o = fa.d1[2][8*i +: 8];        // d17 literal index
      o = fa.d1[lo+1][8*i +: 8];     // d18 expression index
      o = fa.d1[PD][8*i +: 8];       // d19 package localparam index
      o = fa.d1[fa.ix[i]][8*i +: 8]; // d20 NESTED SELECT index
      o = fa.d1[lo][lo +: 8];        // d21 bare-ref base
      o = fa.d1[lo][3 +: 8];         // d22 literal base
      o = fa.d1[lo][PD +: 8];        // d23 package-localparam base
      o = fa.d1[lo][8*i +: PD];      // d24 package-localparam width
      // ---- the LOCAL-VARIABLE CONTROLS (already golden pristine) ---------
      o64 = lv.d1[lo];               // d25
      o   = lv.d1[lo][8*i +: 8];     // d26
      o   = lv.d2[lo][i][15:8];      // d27
      o   = lv.d1[lo][3];            // d28
      o   = lv.pk[8*i +: 8];         // d29
      o   = lv.d1[fa.ix[i]][8*i+:8]; // d30
    endfunction
  endclass
endpackage
