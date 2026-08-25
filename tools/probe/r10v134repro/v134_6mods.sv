// r10v134 grid 6 — MODULE / INTERFACE / STRUCT / DEEP shapes, no classes at all
// where possible, plus repeated instances with different letter case.
package mpk6;
  typedef struct { int fq[$]; int fr[2]; } Rec6;
  typedef struct { Rec6 inner[2]; int top[$]; } Outer6;
endpackage

module mod6;
  import mpk6::*;
  Rec6   Rlist[4];
  Rec6   rlist[4];
  Outer6 Olist[3];
  int    plain2d[2][3];

  initial begin
    // struct array, select then field  (x2 with different case)
    foreach (Rlist[y1]) foreach (Rlist[y1].fq[y2]) $display(y2);
    foreach (rlist[y3]) foreach (rlist[y3].fr[y4]) $display(y4);
    // nested struct: select, field, select, field
    foreach (Olist[y5]) foreach (Olist[y5].inner[y6]) foreach (Olist[y5].inner[y6].fq[y7]) $display(y7);
    // select then field where the field is a queue at depth 1
    foreach (Olist[y8]) foreach (Olist[y8].top[y9]) $display(y9);
    // CONTROLS
    foreach (plain2d[ya,yb]) $display(ya,yb);
    foreach (plain2d[yc]) foreach (plain2d[yc][yd]) $display(yd);
  end

  task automatic t6(ref Rec6 argr[$]);
    foreach (argr[ye]) foreach (argr[ye].fq[yf]) $display(yf);
  endtask

  function automatic int f6();
    Rec6 locr[$];
    foreach (locr[yg]) foreach (locr[yg].fr[yh]) $display(yh);
    return 0;
  endfunction
endmodule

interface if6;
  import mpk6::*;
  Rec6 ir[2];
  initial foreach (ir[yi]) foreach (ir[yi].fq[yj]) $display(yj);
endinterface

program pg6;
  import mpk6::*;
  Rec6 pr[2];
  initial foreach (pr[yk]) foreach (pr[yk].fr[yl]) $display(yl);
endprogram
