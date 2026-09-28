// § mpOrphanLaterWriter209v — r11u217 m07: a later WHOLE-STRUCT connection (.r(sub.req), a struct net: not noted, golden keeps the orphan) and a later bare logic connection (.c(sub.trn)), both after the operation
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
module inner (input logic [7:0] a, input logic b, input logic c, input p::req_t r, output logic [7:0] o);
  assign o = b ? a : (c ? r.wdt : 8'd0);
endmodule
module wrapper (tif.sub sub, output logic [7:0] o);
  inner u (.a(sub.req.wdt), .b(sub.req.wen & sub.trn), .c(sub.trn), .r(sub.req), .o(o));
endmodule
module top (input logic [7:0] din, input logic en, input logic t, input logic [3:0] v, output logic [7:0] o);
  tif s();
  assign s.req.wdt = din;
  assign s.req.wen = en;
  assign s.trn     = t;
  assign s.vec     = v;
  wrapper w (.sub(s.sub), .o(o));
endmodule
