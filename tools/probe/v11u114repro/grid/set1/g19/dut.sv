// face-1 break: UNPACKED struct pattern with a concat member
package q2;
  typedef struct { logic [3:0] pad; logic [11:0] v; } u_t;
  localparam u_t IMPL = '{ pad: 4'h9, v: {6'h15, 6'h2A} };
endpackage
module top(output logic [11:0] o); assign o = q2::IMPL.v; endmodule
