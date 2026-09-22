// r11u94 arm q2 — the synthesized-typespec package hop over EVERY LITERAL
// BASE and through a CHAIN.  The width face answers for the `'d` leaf alone
// (`adjustSize` re-sizes every other const type to the READER's declared
// width); the sign face answers for all but the BINARY const type, whose
// VALUE field our member stamp already writes wrong (r11u91 R5).  The chain
// arms cross an implicit-signing hop with a written-type inner and with
// another implicit hop.
package q2p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int      RI   = 16'd5;
  localparam signed   RSH  = 8'h1A;   // a HEX leaf
  localparam signed   RSB  = 8'b1010; // a BINARY leaf — declined whole
  localparam signed   RSO  = 8'o17;   // an OCTAL leaf
  localparam signed   RSN  = 5;       // an UNSIZED decimal
  localparam signed   RSC  = RI;      // chain: implicit-signed over `int`
  localparam signed [7:0] RSDC = RI;  // chain with a dimension
  localparam unsigned RUC  = RI;      // chain: implicit-unsigned over `int`
endpackage
module q2_pkgbase94;
  localparam logic [7:0] W1 = q2p::RSH;
  localparam logic [7:0] W2 = q2p::RSB;
  localparam logic [7:0] W3 = q2p::RSO;
  localparam logic [7:0] W4 = q2p::RSN;
  localparam logic [7:0] W5 = q2p::RSC;
  localparam logic [7:0] W6 = q2p::RSDC;
  localparam logic [7:0] W7 = q2p::RUC;
  localparam logic [7:0] W8 = q2p::RI;
  localparam q2p::t A = '{bail: 8'hxA, a: W1, b: W2, c: W3, d: W4,
                          e: W5, f: W6, g: W7};
  localparam q2p::t B = '{bail: 8'hxA, a: W8, b: W1, c: W5, d: W6,
                          e: W7, f: W3, g: W4};
  q2_sink #(.R(A)) s1();
  q2_sink #(.R(B)) s2();
endmodule
module q2_sink #(parameter q2p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
