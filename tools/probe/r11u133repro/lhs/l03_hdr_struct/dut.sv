// § impPaLhsDisjointClone133
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  parameter s_t X = '{a:1, b:2};
endpackage
module m import p::*; #(parameter s_t Q = X) (output logic [7:0] o);
  assign o = Q;
endmodule
module top(output logic [7:0] o); m u(.o(o)); endmodule
