// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef union packed { logic [15:0] w; logic [1:0][7:0] b; } u_t;
  localparam u_t X = 16'hbeef;
endpackage
module leaf #(parameter logic [15:0] V = 0)();
endmodule
module dut import pkg::*; #(parameter u_t P = X) ();
  leaf #(.V(P.w)) l();
endmodule
module top(); dut d(); endmodule
