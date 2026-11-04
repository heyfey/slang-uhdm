// § aggParamFoldUnqualWholeSpan158
package pkg;
  typedef struct packed { logic [7:0] key; logic [3:0] val; } init_t;
  parameter init_t InitDefault = '{key: 8'h5a, val: 4'h3};
endpackage
module sub import pkg::InitDefault; #(parameter pkg::init_t Init = InitDefault) (output logic [11:0] o);
  assign o = Init;
endmodule
module dut (output logic [11:0] o); sub u(.o(o)); endmodule
