// § portConnOpLeafChain209: a struct input port member inside a connection operation
package p;
  typedef struct packed { logic [7:0] wdt; logic wen; } req_t;
endpackage
module inner (input logic [7:0] a, input logic b, output logic [7:0] o);
  assign o = b ? a : 8'd0;
endmodule
module top (input p::req_t r, input logic t, output logic [7:0] o);
  inner u (.a(r.wdt), .b(r.wen & t), .o(o));
endmodule
