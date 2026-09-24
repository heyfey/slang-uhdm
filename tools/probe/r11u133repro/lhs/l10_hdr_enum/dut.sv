// § impPaLhsDisjointClone133
package p;
  typedef enum logic [1:0] { A = 2'd0, B = 2'd1 } e_t;
  parameter e_t X = B;
endpackage
module m import p::*; #(parameter e_t Q = X) (output logic [1:0] o);
  assign o = Q;
endmodule
module top(output logic [1:0] o); m u(.o(o)); endmodule
