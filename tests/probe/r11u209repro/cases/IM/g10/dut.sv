// § portConnOpLeafChain209: in a generate block, a local struct member inside a connection operation
package p;
  typedef struct packed { logic [7:0] wdt; logic wen; } req_t;
endpackage
module inner (input logic [7:0] a, input logic b, output logic [7:0] o);
  assign o = b ? a : 8'd0;
endmodule
module wrapper (input p::req_t r, input logic t, output logic [7:0] o);
  p::req_t q;
  assign q = r;
  if (1) begin : g
    inner u (.a(q.wdt), .b(q.wen & t), .o(o));
  end
endmodule
module top (input p::req_t r, input logic t, output logic [7:0] o);
  wrapper w (.r(r), .t(t), .o(o));
endmodule
