// § impArrParamTsOwnRanges242
// Earlgrey's hmac_pkg InitHash shape: an unpacked array of a vector typedef, imported by two
// modules (one instantiating the other), read with a variable index and procedurally.
package hp;
  typedef logic [31:0] w_t;
  parameter w_t IH [8] = '{32'h1, 32'h2, 32'h3, 32'h4, 32'h5, 32'h6, 32'h7, 32'h8};
endpackage
module core import hp::*; (input logic [2:0] i, output logic [31:0] o);
  assign o = IH[i];
endmodule
module top import hp::*; (input logic clk, input logic [2:0] i, output logic [31:0] o, output logic [31:0] p);
  core c (.i(i), .o(o));
  always_ff @(posedge clk) p <= IH[0];
endmodule
