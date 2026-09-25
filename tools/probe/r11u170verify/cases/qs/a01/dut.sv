// § aggParamFoldQualSpanByView163
package pkg;
  typedef struct packed { logic [7:0] key; logic [3:0] cnt; } init_t;
  parameter init_t XLONGNAME = '{key: 8'hA5, cnt: 4'd3};
endpackage
module dut #(parameter pkg::init_t P = pkg::
                                      XLONGNAME) (output logic [11:0] o);
  assign o = P;
endmodule
module top (output logic [11:0] o); dut d(.o(o)); endmodule
