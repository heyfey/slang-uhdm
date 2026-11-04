// § mpOrphanSkipConcat209v — r11u217 m02: a STREAMING operation actual over a struct-net member and a plain member, alone
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
module inner (input logic [8:0] a, output logic [7:0] o);
  assign o = a[7:0];
endmodule
module wrapper (tif.sub sub, output logic [7:0] o);
  inner u (.a({<<{sub.req.wen, sub.req.wdt}}), .o(o));
endmodule
module top (input logic [7:0] din, input logic en, input logic t, input logic [3:0] v, output logic [7:0] o);
  tif s();
  assign s.req.wdt = din;
  assign s.req.wen = en;
  assign s.trn     = t;
  assign s.vec     = v;
  wrapper w (.sub(s.sub), .o(o));
endmodule
