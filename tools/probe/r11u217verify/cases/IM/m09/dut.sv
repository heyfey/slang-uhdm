// § mpOrphanSkipConcat209v — r11u217 m09: a MULTIPLE concatenation actual `{2{sub.req.wen, sub.trn}}` and a positional ASSIGNMENT PATTERN actual `'{sub.req.wen, sub.trn}`, each alone in its instance
package p;
  typedef struct packed { logic [7:0] wdt; logic wen; } req_t;
endpackage
interface tif;
  p::req_t req;
  logic    trn;
  logic [3:0] vec;
  modport sub (input req, input trn, input vec);
endinterface
typedef logic [1:0] pr_t;
module inner (input logic [3:0] a, output logic o);
  assign o = ^a;
endmodule
module inner2 (input pr_t c, output logic o);
  assign o = ^c;
endmodule
module wrapper (tif.sub sub, output logic [7:0] o);
  inner u (.a({2{sub.req.wen, sub.trn}}), .o(o[0]));
  inner2 v (.c('{sub.req.wen, sub.trn}), .o(o[1]));
  assign o[7:2] = '0;
endmodule
module top (input logic [7:0] din, input logic en, input logic t, input logic [3:0] v, output logic [7:0] o);
  tif s();
  assign s.req.wdt = din;
  assign s.req.wen = en;
  assign s.trn     = t;
  assign s.vec     = v;
  wrapper w (.sub(s.sub), .o(o));
endmodule
