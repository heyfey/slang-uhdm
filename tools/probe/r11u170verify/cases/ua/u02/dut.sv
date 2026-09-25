// § aggParamFoldUnqualWholeSpan158
package pkg;
  typedef struct packed { logic [7:0] key; logic [3:0] cnt; } init_t;
  parameter init_t InitDefault = '{key: 8'hA5, cnt: 4'd3};
  parameter init_t InitOther = '{key: 8'h3C, cnt: 4'd1};
endpackage
import pkg::*;
module dut #(parameter init_t Init = InitDefault) (output logic [11:0] o);
  assign o = Init;
endmodule
module top (output logic [11:0] o, output logic [11:0] o2);
  dut d(.o(o));
  dut #(.Init(InitOther)) d2(.o(o2));
endmodule
