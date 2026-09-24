package mask_pkg;
  logic [31:0] v;
  logic [7:0] u [4];
endpackage
module top (input logic s, input logic [1:0] k, output logic [7:0] o);
  import mask_pkg::*;
  assign o = s ? v[7:0] : '0;
endmodule
