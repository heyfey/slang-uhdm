package mask_pkg;
  localparam logic [1:0][7:0] ARR = 16'hA55A;
endpackage
module top (input logic s, output logic [3:0] o);
  assign o = s ? mask_pkg::ARR[1][0 +: 4] : '0;
endmodule
