// face-1 break: packed array of packed struct, positional
package q2;
  typedef struct packed { logic [3:0] a; logic [7:0] v; } e_t;
  localparam e_t [1:0] ARR = '{ '{a: 4'h1, v: {4'h2, 4'h3}}, '{a: 4'h4, v: {4'h5, 4'h6}} };
endpackage
module top(output logic [7:0] o); assign o = q2::ARR[0].v; endmodule
