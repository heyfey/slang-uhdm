// r10v99 ADVERSARIAL -- a NESTED pattern operand reached by the LANDED DIRECT
// carrier (line 9) and by the NEW ternary carrier (line 10).
package pn99;
  typedef struct packed { logic [2:0] a3; logic [4:0] b5; } in_t;
  typedef struct packed { in_t s1; in_t s2; logic [7:0] c8; } out_t;
endpackage
module nsub99 (input logic s, input logic [7:0] d, input pn99::out_t din,
               output pn99::out_t o_dir, output pn99::out_t o_ter);
  assign o_dir = '{ s1 : '{ a3 : '1, b5 : '0 }, s2 : '{ a3 : '0, b5 : '1 }, c8 : d };
  assign o_ter = s ? din : '{ s1 : '{ a3 : '1, b5 : '0 }, s2 : '{ a3 : '0, b5 : '1 }, c8 : '1 };
endmodule
module v99_nest (input logic s, input logic [7:0] d, input pn99::out_t din,
                 output pn99::out_t o_dir, output pn99::out_t o_ter);
  nsub99 u (.s(s), .d(d), .din(din), .o_dir(o_dir), .o_ter(o_ter));
endmodule
