// § mpOrphanLaterWriter209v — r11u217 m03: the operation connection FIRST, then a later SINGLE-SELECT connection of a logic member (.d(sub.vec[1])) and a later bare connection of the other operand in a second instance
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
module inner (input logic [7:0] a, input logic b, input logic d, output logic [7:0] o);
  assign o = b ? a : {7'd0, d};
endmodule
module one (input logic x, output logic y);
  assign y = x;
endmodule
module wrapper (tif.sub sub, output logic [7:0] o);
  logic y1;
  inner u (.a(sub.req.wdt), .b(sub.req.wen & sub.vec[0]), .d(sub.vec[1]), .o(o));
  one   k (.x(sub.trn), .y(y1));
endmodule
module top (input logic [7:0] din, input logic en, input logic t, input logic [3:0] v, output logic [7:0] o);
  tif s();
  assign s.req.wdt = din;
  assign s.req.wen = en;
  assign s.trn     = t;
  assign s.vec     = v;
  wrapper w (.sub(s.sub), .o(o));
endmodule
