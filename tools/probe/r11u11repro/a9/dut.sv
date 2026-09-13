// a9 — NEGATIVE CONTROLS on the assembled base of a5.
//   n1  the member select sits inside an OPERATION (`C.B + 0`)   -> the slice
//       rule must NOT reach it; the decimal fold stands.
//   n2  a WHOLE-parameter actual (`.H(C)`)                       -> not a select.
//   n3  a member of a member (`C.N.X`)                           -> not a bare
//       single-level member select of a parameter.
package p;
  typedef struct packed {
    int unsigned X;
    int unsigned Y;
  } sub_t;
  typedef struct packed {
    int unsigned       A;
    int unsigned       B;
    sub_t              N;
    logic [15:0][63:0] WIDE;
  } cfg_t;
  function automatic cfg_t mk(input bit e);
    cfg_t c;
    c.WIDE = {16{64'h0}};
    c.A = 32;
    c.B = e == 1'b1 ? (c.A / 16) : 1;
    c.N.X = 5;
    c.N.Y = 6;
    return c;
  endfunction
endpackage

module top();
  parameter p::cfg_t C = p::mk(1'b1);
  leaf   #(.W(C.B + 0)) n1();
  holder #(.H(C))       n2();
  leaf   #(.W(C.N.X))   n3();
  leaf   #(.W(C.B))     p1();   // the POSITIVE control in the same design
endmodule

module leaf #(parameter int unsigned W = 2) ();
endmodule

module holder #(parameter p::cfg_t H = '0) ();
endmodule
