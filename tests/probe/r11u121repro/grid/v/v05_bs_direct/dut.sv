package mask_pkg;
  logic [31:0] v;
  logic [7:0] u [4];
endpackage
module top (input logic s, input logic [1:0] k, output logic [7:0] o);
  assign o = mask_pkg::v[3];
endmodule
