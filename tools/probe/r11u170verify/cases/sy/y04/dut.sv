// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [15:0] key; logic [3:0] cnt; } init_t;
  localparam init_t InitDefault = '1;
endpackage
module leaf #(parameter logic [15:0] K = '0) (output logic [15:0] o); assign o = K; endmodule
module mid import pkg::*; #(parameter init_t I = InitDefault) (output logic [15:0] o);
  leaf #(.K(I.key)) l(.o(o));
endmodule
module dut import pkg::*; #(parameter init_t Init = InitDefault) (output logic [15:0] o);
  mid #(.I(Init)) m(.o(o));
endmodule
module top (output logic [15:0] o); dut d(.o(o)); endmodule
