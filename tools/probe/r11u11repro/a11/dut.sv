// a11 — THE RE-PASS.  The member select of an assembled base is handed to a
// child, and the child hands its own formal on to a grandchild.  The second hop
// is a BARE PARAMETER REFERENCE, not a member select, so it must take the
// re-pass arms that already exist — the slice rule is the first hop only.
package p;
  typedef struct packed {
    int unsigned       A;
    logic [3:0]        L4;
    logic [15:0][63:0] WIDE;
  } cfg_t;
  function automatic cfg_t mk(input bit e);
    cfg_t c;
    c.WIDE = {16{64'h0}};
    c.A  = 32;
    c.L4 = e == 1'b1 ? 4'b1010 : 4'b0;
    return c;
  endfunction
endpackage

module top();
  parameter p::cfg_t C = p::mk(1'b1);
  mid #(.W(C.L4)) u1();
endmodule

module mid #(parameter int unsigned W = 2) ();
  leaf #(.V(W)) g1();
endmodule

module leaf #(parameter int unsigned V = 2) ();
endmodule
