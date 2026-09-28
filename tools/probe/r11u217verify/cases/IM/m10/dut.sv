// § mpOrphanSkipConcat209v — r11u217 m10: a STREAMING actual with a slice size over three operands `{<<2{sub.req.wen, sub.trn, sub.req.wdt[1:0]}}` and a concatenation whose operand is a binary operation on a struct-net member (the binary operation nested)
package p;
  typedef struct packed { logic [7:0] wdt; logic wen; } req_t;
endpackage
interface tif;
  p::req_t req;
  logic    trn;
  logic [3:0] vec;
  modport sub (input req, input trn, input vec);
endinterface
module inner (input logic [3:0] a, output logic o);
  assign o = ^a;
endmodule
module wrapper (tif.sub sub, output logic [7:0] o);
  inner u (.a({<<2{sub.req.wen, sub.trn, sub.req.wdt[1:0]}}), .o(o[0]));
  inner v (.a({sub.req.wen & sub.trn, sub.trn, sub.vec[1:0]}), .o(o[1]));
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
