// § modportOpOrphanReparent209 — r11u217 m08: the triggering operation in a GENERATE-scope instance inside a for loop, and a replication-and-concatenation around a binary operation (the operation nested in a concatenation)
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
module inner (input logic b, input logic [1:0] c, output logic o);
  assign o = b ^ c[0];
endmodule
module wrapper (tif.sub sub, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : gl
    inner u (.b(sub.req.wen & sub.vec[k]), .c({sub.req.wen & sub.trn, sub.trn}), .o(o[k]));
  end
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
