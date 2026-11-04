// § modportOpOrphanReparent209 — r11u217 m04: TWO modport ports of the same interface instance (sub and mon) in one wrapper, each with a triggering operation connection
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
module wrapper2 (tif.sub sub, tif.mon mon, output logic o, output logic q);
  inner u (.b(sub.req.wen & sub.trn), .o(o));
  inner v (.b(mon.req.wen ^ mon.trn), .o(q));
endmodule
module top (input logic en, input logic t, output logic o, output logic q);
  tif s();
  assign s.req.wdt = 8'd0;
  assign s.req.wen = en;
  assign s.trn     = t;
  assign s.vec     = 4'd0;
  wrapper2 w (.sub(s.sub), .mon(s.mon), .o(o), .q(q));
endmodule
