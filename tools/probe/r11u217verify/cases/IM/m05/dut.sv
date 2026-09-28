// § portConnOpLeafChain209 — r11u217 m05: connection operations WITHOUT a struct net (logic members of a modport, a local vector and a port bit) in a unary, a binary and a ternary actual (the leaf-chain law fires, the orphan law must not)
package p;
  typedef struct packed { logic [7:0] wdt; logic wen; } req_t;
endpackage
interface tif;
  p::req_t req;
  logic    trn;
  logic [3:0] vec;
  modport sub (input req, input trn, input vec);
  modport mon (input req, input trn);
endinterface
module inner (input logic b, output logic o);
  assign o = b;
endmodule
module wrapper (tif.sub sub, output logic [7:0] o);
  logic [3:0] l;
  assign l = sub.vec;
  inner u0 (.b(~sub.trn), .o(o[0]));
  inner u1 (.b(sub.vec[2] & l[1]), .o(o[1]));
  inner u2 (.b(sub.trn ? sub.vec[0] : l[3]), .o(o[2]));
  assign o[7:3] = '0;
endmodule
module top (input logic [7:0] din, input logic en, input logic t, input logic [3:0] v, output logic [7:0] o);
  tif s();
  assign s.req.wdt = din;
  assign s.req.wen = en;
  assign s.trn     = t;
  assign s.vec     = v;
  wrapper w (.sub(s.sub), .o(o));
endmodule
