// v149b arm -- BOUNDED QUEUE BOUND FORMS: zero, a parameter, a folded
// expression, a localparam, and a plain literal, next to an unbounded one.
package Beta9_pkg;
  parameter int LIMIT = 5;
  localparam int OTHER = 2;
  typedef struct {
    byte     paramBound[$:LIMIT];
    byte     exprBound[$:2+3];
    byte     lpBound[$:OTHER];
    byte     litBound[$:31];
    byte     noBound[$];
  } bound_faces_t;
  bound_faces_t theBounds;
endpackage

module bounds_top;
  import Beta9_pkg::*;
  bound_faces_t b9;
  initial b9.litBound.push_back(8'd1);
endmodule
