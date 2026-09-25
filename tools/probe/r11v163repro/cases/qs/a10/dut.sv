// § aggParamFoldQualSpanByView163
package pkg;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam s_t XLONG = '0;
endpackage
module dut #(parameter pkg::s_t P = pkg::XLONG) (output logic [3:0] o);
  assign o = P.a;
endmodule
module top(output logic [3:0] o); dut d(.o(o)); endmodule
