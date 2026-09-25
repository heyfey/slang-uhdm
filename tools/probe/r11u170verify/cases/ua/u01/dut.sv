// § aggParamFoldUnqualWholeSpan158
package pkg;
  typedef struct packed { logic [7:0] key; logic [3:0] cnt; } init_t;
  parameter init_t InitDefault = '{key: 8'hA5, cnt: 4'd3};
endpackage
module dut import pkg::*; #(parameter init_t Init = (InitDefault)) (output logic [11:0] o);
  assign o = Init;
endmodule
module top (output logic [11:0] o); dut d(.o(o)); endmodule
