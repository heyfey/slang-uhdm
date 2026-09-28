// § modportOpOrphanReparent209 — r11u217 m01: a struct-net member operand inside an ASSIGNMENT PATTERN actual beside a binary-operation actual (the operation triggers, the pattern must not)
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
typedef struct packed { logic a; logic b; } pr_t;
module inner (input logic [7:0] a, input logic b, input pr_t c, output logic [7:0] o);
  assign o = b ? a : {6'd0, c};
endmodule
module wrapper (tif.sub sub, output logic [7:0] o);
  inner u (.a(sub.req.wdt), .b(sub.req.wen | sub.trn), .c('{a: sub.req.wen, b: sub.trn}), .o(o));
endmodule
module top (input logic [7:0] din, input logic en, input logic t, input logic [3:0] v, output logic [7:0] o);
  tif s();
  assign s.req.wdt = din;
  assign s.req.wen = en;
  assign s.trn     = t;
  assign s.vec     = v;
  wrapper w (.sub(s.sub), .o(o));
endmodule
