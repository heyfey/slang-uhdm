// § aggParamFoldQualSpanByView163
package pkg;
  typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
  localparam u_t XLONG = 8'h12;
endpackage
module dut #(parameter pkg::u_t P = pkg::XLONG) (output logic [7:0] o);
  assign o = P.a;
endmodule
module top(output logic [7:0] o); dut d(.o(o)); endmodule
