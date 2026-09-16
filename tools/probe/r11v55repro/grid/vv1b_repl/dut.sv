// r11v55 — REPLICATED assignment pattern as the struct parameter's value.
package p;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } dup_t;
  localparam dup_t REPL = '{2{8'd5}};
endpackage
module dut #(parameter p::dup_t P2 = p::REPL)
           (output logic [31:0] o_a, output logic [31:0] o_b);
  assign o_a = P2.a;
  assign o_b = P2.b;
endmodule
