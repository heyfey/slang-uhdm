// a10 — THE BOUNDARY THE LAW MUST NOT CROSS: a base that is NOT function-built.
// `C` is a plain struct-pattern localparam, so its value never passes through
// the v1.87 struct_var assembler at all; § structParamMemberOvBinary's own
// `asmOk8` path owns it and must be byte-for-byte what it was.
//   w1  every member inside 64 bits   -> the slice (asmOk8 passes today)
//   w2  a 1024-bit member             -> asmOk8 blocks today
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
  } small_t;
  typedef struct packed {
    int unsigned       A;
    int unsigned       B;
    logic [15:0][63:0] WIDE;
  } big_t;
  localparam small_t S = '{A: 32, B: 2};
  localparam big_t   G = '{A: 32, B: 2, WIDE: {16{64'h0}}};
endpackage

module top();
  leaf #(.W(p::S.B)) w1();
  leaf #(.W(p::G.B)) w2();
endmodule

module leaf #(parameter int unsigned W = 2) ();
endmodule
