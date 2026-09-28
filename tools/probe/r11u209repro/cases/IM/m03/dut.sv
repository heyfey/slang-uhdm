// § portConnOpLeafChain209: a unary operation over a member path
package p;
  typedef struct packed { logic [7:0] wdt; logic wen; } req_t;
endpackage
interface tif;
  p::req_t req;
  logic    trn;
  modport sub (input req, input trn);
endinterface
module inner (input logic [7:0] a, input logic b, output logic [7:0] o);
  assign o = b ? a : 8'd0;
endmodule
module wrapper (tif.sub sub, output logic [7:0] o);
  inner u (.a(sub.req.wdt), .b(~sub.req.wen), .o(o));
endmodule
module top (input logic [7:0] din, input logic en, input logic t, output logic [7:0] o);
  tif s();
  assign s.req.wdt = din;
  assign s.req.wen = en;
  assign s.trn     = t;
  wrapper w (.sub(s.sub), .o(o));
endmodule
