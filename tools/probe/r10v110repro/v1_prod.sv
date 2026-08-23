// r10v110 arm v1 — STATEMENT-PRODUCTION / HOME axis for the dyn-array `new[]`
// lvalue.  Every cell pairs an IN-LAW dotted `new [n]` with a control in the
// same slot.  Naming deliberately irregular (Qq/ZZ/n3/wideName) so no cell can
// agree by a uniform-naming accident.
package vp1;
  class Blob;
    byte  bs[];
    int   iv[];
    Blob  nextOne;
    int   scalarF;
  endclass
endpackage

module v1top;
  import vp1::*;
  Blob Qq;
  Blob ZZ;
  int  n3;
  logic clkV1;

  // --- always/always_comb/always_ff/final homes
  always @(posedge clkV1) begin
    Qq.bs = new [3];            // v1a01 always@ + new[]      (in law)
    Qq.scalarF = 3;             // v1a02 control
  end
  always_comb begin
    ZZ.iv = new [n3];           // v1a03 always_comb + new[]   (in law)
    ZZ.scalarF = n3;            // v1a04 control
  end
  final begin
    Qq.iv = new [2];            // v1a05 final + new[]         (in law)
    Qq.nextOne = new ();        // v1a06 control class new
  end

  // --- named block / nested begin / repeat / forever / do-while
  initial begin : NAMED_V1
    Blob loc1;
    loc1 = new();
    loc1.bs = new [4];          // v1a07 named block + new[]   (in law)
    begin
      Blob loc2;
      loc2 = new();
      loc2.iv = new [5];        // v1a08 nested begin (unnamed)(in law)
      loc2.scalarF = 5;         // v1a09 control
    end
    repeat (2) loc1.iv = new [6];   // v1a10 repeat body        (in law)
    forever begin
      loc1.bs = new [7];        // v1a11 forever body          (in law)
      break;
    end
  end

  // --- fork branches (join / join_any)
  initial begin
    Blob fk;
    fk = new();
    fork
      fk.bs  = new [8];         // v1a12 fork join branch      (in law)
      begin fk.iv = new [9]; end// v1a13 fork begin branch     (in law)
    join
    fork
      fk.iv = new [10];         // v1a14 fork join_any         (in law)
    join_any
  end

  // --- static / automatic task+function homes at module level
  task static st_v1();
    Blob sv;
    sv = new();
    sv.bs = new [11];           // v1a15 STATIC task           (in law)
    sv.scalarF = 11;            // v1a16 control
  endtask
  task automatic at_v1();
    Blob av;
    av = new();
    av.iv = new [12];           // v1a17 AUTOMATIC task        (in law)
  endtask
  function automatic void af_v1();
    Blob bv;
    bv = new();
    bv.bs = new [13];           // v1a18 AUTOMATIC function    (in law)
  endfunction

  // --- case / casex / while / disable-free constructs
  initial begin
    Blob cv; int selv;
    cv = new(); selv = 1;
    case (selv)
      0: begin cv.bs = new [14]; end   // v1a19 case begin item (in law)
      1: cv.iv = new [15];             // v1a20 case bare item  (in law)
      default: cv.scalarF = 0;         // v1a21 control
    endcase
    casex (selv)
      1'b?: cv.bs = new [16];          // v1a22 casex item      (in law)
    endcase
    while (selv > 0) begin
      cv.iv = new [17];                // v1a23 while body      (in law)
      selv--;
    end
  end
endmodule

package vp1b;
  import vp1::*;
  // --- package task / package function homes
  task pk_t_v1();
    Blob pv;
    pv = new();
    pv.bs = new [18];          // v1a24 PACKAGE task           (in law)
    pv.scalarF = 18;           // v1a25 control
  endtask
  function void pk_f_v1();
    Blob pf;
    pf = new();
    pf.iv = new [19];          // v1a26 PACKAGE function       (in law)
  endfunction
  // --- out-of-body TASK (not function)
  class OobHome;
    Blob ob;
    extern task oob_t_v1();
  endclass
  task OobHome::oob_t_v1();
    ob = new();
    ob.bs = new [20];          // v1a27 OUT-OF-BODY task       (in law)
    ob.scalarF = 20;           // v1a28 control
  endtask
endpackage
