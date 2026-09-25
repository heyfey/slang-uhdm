// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [15:0] key; logic [3:0] cnt; } init_t;
  localparam init_t InitDefault = '{key: 16'hA5A5, cnt: 4'd9};
endpackage
module leaf #(parameter int C = 0) (output logic [3:0] o); assign o = C[3:0]; endmodule
module dut import pkg::*; #(parameter init_t Init = InitDefault) (output logic [3:0] o);
  localparam int CNT = Init.cnt;
  leaf #(.C(CNT)) l(.o(o));
endmodule
module top (output logic [3:0] o); dut d(.o(o)); endmodule
