// r10v99 -- where exactly does GOLDEN's size walk stop when a NESTED pattern
// is not the first operand?
package pn2;
  typedef struct packed { logic [2:0] a3; logic [4:0] b5; } in_t;
  typedef struct packed { logic [3:0] w4; in_t mid; logic [7:0] w8; logic [1:0] w2; } o_t;
endpackage
module n2sub (input logic s, input logic [7:0] d, input pn2::o_t din,
              output pn2::o_t o_dir, output pn2::o_t o_ter);
  assign o_dir = '{ w4 : '1, mid : '{ a3 : '1, b5 : '0 }, w8 : d, w2 : 2'h1 };
  assign o_ter = s ? din : '{ w4 : '1, mid : '{ a3 : '1, b5 : '0 }, w8 : '1, w2 : 2'h1 };
endmodule
module v99_nest2 (input logic s, input logic [7:0] d, input pn2::o_t din,
                  output pn2::o_t o_dir, output pn2::o_t o_ter);
  n2sub u (.*);
endmodule
