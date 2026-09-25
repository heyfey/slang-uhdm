// § aggParamFoldQualSpanByView163
package pkg;
  typedef struct packed { logic [7:0] key; logic [3:0] cnt; } init_t;
  parameter init_t XA = '{key: 8'hA5, cnt: 4'd3};
endpackage
module dut #(parameter pkg::init_t P = pkg::XA) (output logic [11:0] o);
  assign o = P;
endmodule
module top (output logic [11:0] o [2]);
  for (genvar g = 0; g < 2; g++) begin : G
    dut d(.o(o[g]));
  end
endmodule
