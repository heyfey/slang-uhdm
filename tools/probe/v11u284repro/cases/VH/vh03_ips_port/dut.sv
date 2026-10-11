// § hpSelPortConnFoldChain284
package pk;
  localparam logic [3:0] DC = 4'h2;
  typedef struct packed { logic [7:0] lo; logic [7:0] hi; } inner_t;
  typedef struct packed { inner_t a; logic [15:0] b; } outer_t;
endpackage
module sub (input logic [31:0] a, output logic [31:0] b);
  assign b = a;
endmodule
module dut (input pk::outer_t o, output logic [31:0] y);
  sub u1 (.a(o.a[pk::DC +: 2]), .b(y));
endmodule
