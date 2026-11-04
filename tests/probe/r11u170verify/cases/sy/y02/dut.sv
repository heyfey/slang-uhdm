// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef enum logic [1:0] { A, B, C } mode_e;
  typedef struct packed { mode_e mode; logic [3:0][1:0] lanes; } cfg_t;
  parameter cfg_t CfgDefault = '{mode: B, lanes: 8'h1B};
endpackage
module dut import pkg::*; #(parameter cfg_t Cfg = CfgDefault) (output logic [9:0] o);
  assign o = Cfg;
endmodule
module top (output logic [9:0] o); dut d(.o(o)); endmodule
