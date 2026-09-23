// default-keyed pattern whose value is a concat
package q2;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } impl_t;
  localparam impl_t IMPL = '{ default: {4'h1, 4'h2} };
endpackage
module top(output logic o);
  assign o = 1'b0;
endmodule
