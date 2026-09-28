// § modportOpOrphanReparent209: a nested struct member path, the interface signals also read by a second module through the interface
package p;
  typedef struct packed { logic [3:0] x; logic y; } in_t;
  typedef struct packed { in_t in; logic wen; } req_t;
endpackage
interface tif;
  p::req_t req;
  logic    trn;
  modport sub (input req, input trn);
endinterface
module inner (input logic [3:0] a, input logic b, output logic [3:0] o);
  assign o = b ? a : 4'd0;
endmodule
module wrapper (tif.sub sub, output logic [3:0] o);
  inner u (.a(sub.req.in.x), .b(sub.req.in.y & sub.trn), .o(o));
endmodule
module mon (tif.sub m, output logic z);
  assign z = m.req.wen ^ m.trn;
endmodule
module top (input p::req_t r, input logic t, output logic [3:0] o, output logic z);
  tif s();
  assign s.req = r;
  assign s.trn = t;
  wrapper w (.sub(s.sub), .o(o));
  mon mm (.m(s.sub), .z(z));
endmodule
