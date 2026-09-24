// a3 — MODULE holder, base ASSEMBLES, every member inside 64 bits.
// The member-select override actual; the base is function-built.
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    bit          F;
  } cfg_t;
  function automatic cfg_t mk(input bit e);
    cfg_t c;
    c.A = 32;
    c.B = e == 1'b1 ? (c.A / 16) : 1;
    c.F = 1'b1;
    return c;
  endfunction
endpackage

module top();
  parameter p::cfg_t C = p::mk(1'b1);
  leaf #(.W(C.B)) u1();
  leaf #(.W(C.A)) u2();
endmodule

module leaf #(parameter int unsigned W = 2) ();
endmodule
