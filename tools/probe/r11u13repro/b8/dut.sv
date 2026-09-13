// b8 — NEGATIVE CONTROLS on an ASSEMBLED base.  None of these is a BARE
// reference to the base, so none may move:
//   n1  a member select as the actual        (§ memSelAsmBaseOv owns it)
//   n2  a CAST around the reference
//   n3  a base that is NOT function-built    (a plain pattern localparam)
//   n4  an INT-valued localparam read bare   (§ elabOvRefIntConst owns it)
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
  } cfg_t;
  function automatic cfg_t mk(input bit e);
    cfg_t c;
    c.A = 32;
    c.B = e == 1'b1 ? (c.A / 16) : 1;
    return c;
  endfunction
  localparam cfg_t C = mk(1'b1);
  localparam cfg_t G = '{A: 32, B: 2};     // NOT function-built
  localparam int   N = 32 / 16;            // INT-valued
endpackage

module top
  import p::*;
();
  leaf   #(.W(C.B))          n1();
  holder #(.H(cfg_t'(p::C))) n2();
  holder #(.H(p::G))         n3();
  leaf   #(.W(p::N))         n4();
endmodule

module leaf   #(parameter int unsigned W = 2) (); endmodule
module holder
  import p::*;
#(parameter cfg_t H = '0) ();
endmodule
