// r10uvm110 arm a4 — the SLOT axis.  Every statement slot § thisSuperNewAssign
// NoStmt3's decode separates (fork, foreach, case item, while, if-sole-branch,
// constructor body) plus program / interface / generate homes, each carrying
// ONE in-law dotted `new [n]` and ONE control.  Numbers and casing differ from
// a1/a2/a3 on purpose.
package qpk110;
  typedef bit bvec110[];
  class Node110;
    bvec110 payload;
    Node110 peer;
    int     tally;
  endclass

  class Slots110;
    Node110 N;
    int      k4;

    function new();
      N = new();
      N.payload = new [11];        // g01 CONSTRUCTOR body  (in law)
      N.tally   = 11;              // g02 constructor control
    endfunction

    task forkz();
      Node110 fz; fz = new();
      fork
        fz.payload = new [12];     // g03 fork slot (in law)
        fz.tally   = 12;           // g04 fork control
      join_none
    endtask

    function void eachz();
      Node110 ez; int L4[3];
      ez = new();
      foreach (L4[i]) begin
        ez.payload = new [i];      // g05 foreach body (in law)
        ez.tally   = i;            // g06 foreach control
      end
    endfunction

    function void casez4(int sel);
      Node110 cz; cz = new();
      case (sel)
        0: cz.payload = new [13];  // g07 case item, SOLE stmt (in law)
        1: cz.tally   = 13;        // g08 case item control
        default: cz.peer = new (); // g09 case item, class new (control)
      endcase
    endfunction

    function void solez(int f);
      Node110 sz; sz = new();
      if (f) sz.payload = new [14];   // g10 sole if branch (in law)
      do sz.tally = 14; while (0);    // g11 do-while control
    endfunction
  endclass
endpackage

interface ifc110;
  import qpk110::*;
  Node110 IN4;
  int     ik4;
  initial begin
    IN4 = new();
    IN4.payload = new [15];        // g12 INTERFACE body (in law)
    IN4.tally   = 15;              // g13 interface control
  end
endinterface

program prg110;
  import qpk110::*;
  Node110 PN4;
  initial begin
    PN4 = new();
    PN4.payload = new [16];        // g14 PROGRAM body (in law)
    PN4.tally   = 16;              // g15 program control
  end
endprogram

module gen110;
  import qpk110::*;
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : GBLK
      Node110 GN4;
      initial begin
        GN4 = new();
        GN4.payload = new [17];    // g16 GENERATE-scope body (in law)
        GN4.tally   = 17;          // g17 generate control
      end
    end
  endgenerate
endmodule

module top110d;
  ifc110 IW();
  gen110 GU();
endmodule
