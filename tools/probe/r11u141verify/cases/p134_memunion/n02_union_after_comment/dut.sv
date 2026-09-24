// § memberAnonUnionAtKeyword134
// case n02: a nested anonymous union member written after a comment line, with packed dimensions
module top(input logic [15:0] i, output logic [7:0] o);
  typedef struct packed {
    // the payload
    union packed { logic [7:0] a; logic [7:0] b; } [1:0] pl;
  } s_t;
  s_t v;
  assign v = i;
  assign o = v.pl[0].a;
endmodule
