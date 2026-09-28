// § portConnOpLeafChain209: a member path inside an operation in an ordered connection of a module array
package p;
  typedef struct packed { logic [1:0] d; logic v; } req_t;
endpackage
module inner (input logic b, output logic o);
  assign o = b;
endmodule
module top (input p::req_t r, input logic t, output logic [1:0] o);
  inner u [1:0] ({2{r.v & t}}, o);
endmodule
