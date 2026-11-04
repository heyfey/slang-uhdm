// § aggParamFoldQualSpanByView163
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t X = 16'h1234;
endpackage
module leaf #(parameter logic [7:0] V = 0) (output logic [7:0] o); assign o = V; endmodule
module dut #(parameter pkg::s_t P = pkg::X) (output logic [7:0] o [2]);
  for (genvar g = 0; g < 2; g++) begin : G
    leaf #(.V(g ? P.a : P.b)) l(.o(o[g]));
  end
endmodule
module top (output logic [7:0] o [2]); dut d(.o(o)); endmodule
