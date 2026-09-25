// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [7:0] key; logic [3:0] cnt; } init_t;
  parameter init_t InitDefault = '{key: 8'hA5, cnt: 4'd3};
endpackage
module leaf import pkg::*; #(parameter init_t Init = InitDefault) (output logic [11:0] o);
  assign o = Init;
endmodule
module mid import pkg::*; #(parameter init_t MInit = InitDefault) (output logic [11:0] o);
  leaf #(.Init(MInit)) l(.o(o));
endmodule
module top (output logic [11:0] o); mid m(.o(o)); endmodule
