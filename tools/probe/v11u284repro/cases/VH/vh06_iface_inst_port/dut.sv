// § hpSelPortConnFoldChain284
package pk;
  localparam logic [3:0] DC = 4'h2;
  typedef struct packed { logic [7:0] lo; logic [7:0] hi; } inner_t;
  typedef struct packed { inner_t a; logic [15:0] b; } outer_t;
endpackage
interface ifc (input logic [31:0] a);
  logic [31:0] b;
  assign b = a;
endinterface
module dut (input pk::outer_t o, output logic [31:0] y);
  ifc u1 (.a(o.a[pk::DC-1:0]));
  assign y = u1.b;
endmodule
