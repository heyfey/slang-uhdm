// § aggParamFoldQualSpanByView163
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t XLONG = 16'h1234;
endpackage
module leaf #(parameter logic [7:0] V = 0)(); endmodule
module dut ();
  for (genvar i = 0; i < 2; i++) begin : g
    localparam pkg::s_t L = pkg::XLONG;
    leaf #(.V(L.b)) l();
  end
endmodule
module top(); dut d(); endmodule
