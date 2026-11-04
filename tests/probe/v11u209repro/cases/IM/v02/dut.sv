// § mpOrphanSkipConcat209v: a concatenation connection reading a struct member path and a plain member (no orphan in golden)
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
  logic [7:0] x;
  inner u (.a({sub.req.wen, sub.trn, sub.req.wdt[5:0]}), .b(sub.trn), .o(o));
endmodule
module top (input logic [7:0] din, input logic en, input logic t, output logic [7:0] o);
  tif s();
  assign s.req.wdt = din;
  assign s.req.wen = en;
  assign s.trn     = t;
  wrapper w (.sub(s.sub), .o(o));
endmodule
