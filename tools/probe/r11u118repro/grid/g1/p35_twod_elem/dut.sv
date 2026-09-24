package mask_pkg;
  localparam logic [1:0][1:0][3:0] PA = 16'h1234;
endpackage
module top (input logic s, input logic i, output logic [3:0] o);
  assign o = s ? mask_pkg::PA[i][0] : '0;
endmodule
