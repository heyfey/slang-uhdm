// § aggParamFoldUnqualWholeSpan158
package pkg;
  typedef struct packed { logic [7:0] key; logic [3:0] cnt; } init_t;
  parameter init_t InitDefault = '{key: 8'h5A, cnt: 4'd7};
endpackage
module leaf #(parameter logic [7:0] K = '0) (output logic [7:0] o); assign o = K; endmodule
module dut import pkg::*; #(parameter init_t Init = InitDefault) (output logic [7:0] o);
  leaf #(.K(Init.key)) l(.o(o));
endmodule
module top (output logic [7:0] o); dut d(.o(o)); endmodule
