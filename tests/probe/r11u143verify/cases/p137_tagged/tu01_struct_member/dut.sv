// § taggedUnionElabSpan137
// case tu01: a tagged packed union with a struct member
module top(output logic [7:0] o);
  union tagged packed {
    struct packed { logic [3:0] a; logic [3:0] b; } s;
    logic [7:0] w;
  } un;
  initial un = tagged w (8'h3C);
  assign o = un.w;
endmodule
