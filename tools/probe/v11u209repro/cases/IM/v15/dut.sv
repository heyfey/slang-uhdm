// § portConnOpLeafChain209: a three-level struct member path inside a connection operation
package p;
  typedef struct packed { logic x; logic y; } in_t;
  typedef struct packed { in_t a; logic w; } req_t;
endpackage
module inner (input logic b, output logic o);
  assign o = b;
endmodule
module top (input p::req_t r, input logic t, output logic o);
  p::req_t q;
  assign q = r;
  inner u (.b(q.a.y | t), .o(o));
endmodule
