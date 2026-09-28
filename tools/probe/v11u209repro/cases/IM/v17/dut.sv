// § portConnOpLeafChain209: a struct member path inside a function call inside a connection operation
package p;
  typedef struct packed { logic [3:0] d; logic v; } req_t;
endpackage
module inner (input logic b, output logic o);
  assign o = b;
endmodule
module top (input p::req_t r, input logic t, output logic o);
  function automatic logic inv(input logic x); return ~x; endfunction
  inner u (.b(inv(r.v) & r.d[0] & t), .o(o));
endmodule
