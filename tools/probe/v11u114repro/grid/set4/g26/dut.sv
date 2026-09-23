// face-1 break: macro-expanded concat members with different arguments (span-key collision probe)
`define C(x) {x, 4'h2}
package q2;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t IMPL = '{ a: `C(4'h1), b: `C(4'h3) };
endpackage
module top(output logic [7:0] o, p); assign o = q2::IMPL.a; assign p = q2::IMPL.b; endmodule
