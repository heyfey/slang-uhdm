// v125 arm V1 — PORT connections (output / inout) with and without a type change.
// The adversarial question: slang binds an output/inout PORT connection through
// Expression::bindLValue(expr, type, ...) too, so a width mismatch there also
// yields Conversion(EmptyArgument).  Does the widened predicate move a port?
module Sink_Wide (output bit [63:0] q_out, inout wire [15:0] z_io, input int k_in);
endmodule

module Sink_Named (output logic [7:0] r_out, input logic [7:0] s_in);
endmodule

module Top_Ports;
  bit  [31:0] narrowOut;      // narrower than the 64-bit output port
  bit  [63:0] sameOut;        // exact match
  wire [7:0]  narrowIo;       // narrower than the 16-bit inout port
  wire [15:0] sameIo;
  logic [7:0] r8, s8;
  logic [3:0] r4;
  int         kk;

  Sink_Wide  u_narrow (.q_out(narrowOut), .z_io(narrowIo), .k_in(kk));
  Sink_Wide  u_same   (.q_out(sameOut),   .z_io(sameIo),   .k_in(kk));
  Sink_Named u_exact  (.r_out(r8), .s_in(s8));
  Sink_Named u_short  (.r_out(r4), .s_in(s8));
  Sink_Named u_pos    (r8, s8);
endmodule
