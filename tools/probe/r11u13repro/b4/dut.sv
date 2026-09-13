// b4 — b3's BAIL twin (member `U` is never written by the builder).
// BYTE-IDENTICAL on both binaries is the requirement.
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    int unsigned U;
  } cfg_t;
endpackage

module top ();
  function automatic p::cfg_t mk(input bit e);
    p::cfg_t c;
    c.A = 32;
    c.B = e == 1'b1 ? (c.A / 16) : 1;
    return c;
  endfunction
  localparam p::cfg_t C = mk(1'b1);
  parameter  p::cfg_t D = C;
  holder #(.H(C)) u1();
  holder #(.H(D)) u2();
endmodule

module holder #(parameter p::cfg_t H = '0) (); endmodule
