// § aggParamFoldQualSpanByView163
package pkg;
  typedef struct packed { logic [7:0] key; logic [3:0] cnt; } init_t;
  parameter init_t XA = '{key: 8'hA5, cnt: 4'd3};
  parameter init_t XB = '{key: 8'h11, cnt: 4'd2};
endpackage
module dut #(parameter pkg::init_t P = pkg::XA) (output logic [11:0] o);
  assign o = P;
endmodule
module top (output logic [11:0] o, output logic [11:0] o2);
  dut d(.o(o));
  dut #(.P(pkg::XB)) d2(.o(o2));
endmodule
