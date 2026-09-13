// a5 — MODULE holder, base ASSEMBLES, one member 1024 BITS WIDE.
// THE R0 FACE, minimised out of FuncStructValSimple: `asmOk8`'s ">64-bit
// member" fence is the only thing that kept us off the slice, and the v1.87
// assembler has no such fence.
package p;
  typedef struct packed {
    int unsigned       A;
    int unsigned       B;
    logic [15:0][63:0] WIDE;
  } cfg_t;
  function automatic cfg_t mk(input bit e);
    cfg_t c;
    c.WIDE = {16{64'h0}};
    c.A = 32;
    c.B = e == 1'b1 ? (c.A / 16) : 1;
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
