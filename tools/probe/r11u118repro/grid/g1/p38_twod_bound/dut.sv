package mask_pkg;
  localparam logic [1:0][7:0] ARR = 16'hA55A;
endpackage
module top #(parameter int W = 4) (input logic s, output logic [W-1:0] o);
  assign o = s ? mask_pkg::ARR[0][W-1:0] : '0;
endmodule
