// § portConnOpLeafChain209: a bit-select on the path
package p;
  typedef struct packed { logic [7:0] wdt; logic wen; } req_t;
endpackage
interface tif;
  logic trn;
  logic [7:0] d;
endinterface
module inner (input logic [7:0] a, input logic b, output logic [7:0] o);
  assign o = b ? a : 8'd0;
endmodule
module wrapper (input p::req_t r, input logic t, output logic [7:0] o);
  p::req_t q;
  tif s();
  assign q = r;
  assign s.trn = t;
  assign s.d = r.wdt;
  inner u (.a(q.wdt), .b(q.wdt[0] & t), .o(o));
endmodule
module top (input p::req_t r, input logic t, output logic [7:0] o);
  wrapper w (.r(r), .t(t), .o(o));
endmodule
