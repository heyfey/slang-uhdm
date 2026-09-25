// § aggParamFoldUnqualWholeSpan158
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t X = '1;
  localparam s_t Y = 16'h1234;
  localparam s_t Z = '{a: 8'd1, b: 8'd2};
endpackage
module leaf #(parameter logic [7:0] V = 0)();
endmodule
module dut #(parameter pkg::s_t P = pkg::X) ();
  leaf #(.V(P.a)) l();
endmodule
module top(); dut d(); endmodule
