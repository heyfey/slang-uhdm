// face-1 break: package parameter of a typedef'd packed array type with concat elements (positional)
package q2;
  typedef logic [1:0][7:0] a_t;
  localparam a_t A = '{ {4'h1, 4'h2}, {4'h3, 4'h4} };
endpackage
module top(output logic [15:0] o); assign o = q2::A; endmodule
