// vbuvm7 adversarial arm E — POSITION / CONTEXT matrix.
typedef struct { int used; int c; } stE_t;
package pkE;
  typedef struct { int used; } stQ_t;
  stQ_t qq[4];
  function void fpk();
    qq[1].used++;                    // E1 inside a PACKAGE function
  endfunction
endpackage
interface ifE;
  stE_t iarr[4];
  task tif(); iarr[1].used++; endtask // E2 inside an INTERFACE task
endinterface
class holdE;
  stE_t q[4];
  int r;
  function new(); q[0].used++; endfunction     // E3 in a CONSTRUCTOR
  static stE_t sq[4];
  static function void sf(); sq[1].used++; endfunction // E4 STATIC method
  function void f();
    int i; i = 0;
    for (int k = 0; k < 2; q[k].used++) r = k;  // E5 the for-STEP itself
    r = (i > 0) ? q[1].used++ : 0;              // E6 in a TERNARY arm
    r = {q[2].used++};                          // E7 in a CONCATENATION
    fv(q[3].used++);                            // E8 as a CALL ARGUMENT
    while (i < 1) begin q[0].used++; i++; end   // E9 in a WHILE body
    do q[1].c++; while (0);                     // E10 in a DO-WHILE body
    repeat (2) q[2].c++;                        // E11 in a REPEAT body
    case (i) 0: q[3].c++; default: r = 0; endcase // E12 in a CASE item
    unique case (i) 0: q[0].c++; default: r = 1; endcase // E13 unique case
    assert (i == 0) q[1].c++; else r = 2;       // E14 assert action block
  endfunction
  function void fv(int a); r = a; endfunction
endclass
module topE;
  stE_t marr[4];
  genvar g;
  for (g = 0; g < 2; g++) begin : gb
    initial marr[g].used++;                     // E15 inside a GENERATE for
  end
  final marr[3].used++;                         // E16 in a FINAL block
  initial begin
    marr[0].c++;                                // E17 module initial (control)
  end
  always_comb marr[1].c = marr[1].c;
endmodule
