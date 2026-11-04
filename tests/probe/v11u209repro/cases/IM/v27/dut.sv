// § modportOpOrphanReparent209: an operation connection followed by a struct member connection
package p;
  typedef struct packed { logic [7:0] wdt; logic wen; } req_t;
endpackage
interface tif;
  p::req_t req;
  logic    trn;
  logic [3:0] vec;
  modport sub (input req, input trn, input vec);
endinterface
module inner (input logic [7:0] a, input logic b, output logic [7:0] o);
  assign o = b ? a : 8'd0;
endmodule
module innerr (input p::req_t r, input logic b, output logic [7:0] o);
  assign o = b ? r.wdt : 8'd0;
endmodule
module wrapper (tif.sub sub, output logic [7:0] o);
  inner u (.b(sub.req.wen & sub.trn), .a(sub.req.wdt), .o(o));
endmodule
module top (input logic [7:0] din, input logic en, input logic t, output logic [7:0] o);
  tif s();
  assign s.req.wdt = din;
  assign s.req.wen = en;
  assign s.trn     = t;
  assign s.vec     = din[3:0];
  wrapper w (.sub(s.sub), .o(o));
endmodule
