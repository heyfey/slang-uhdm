// struct-typed member whose value is a concat
package q2;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { logic [3:0] pad; in_t s; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, s: {4'h1, 4'h2}, cfg: 2'b11 };
endpackage
module top(output logic o);
  assign o = 1'b0;
endmodule
