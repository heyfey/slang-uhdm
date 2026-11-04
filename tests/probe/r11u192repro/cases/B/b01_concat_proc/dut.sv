// § psBoundPaOwnerName192
package p;
  parameter int unsigned A = 32;
  parameter int unsigned B = 64;
  parameter int unsigned C = B/8;
  parameter int unsigned W = $clog2(C);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] y, output logic [31:0] z);
  assign y = {x[A-1:W], {W{1'b0}}};
  always_comb begin
    z = '0;
    z |= {x[A-1:W], 3'b0};
  end
endmodule
