// v11u90 vy2 -- the delayed assign lives in a GENERATE block; the parameter
// is the enclosing module's.  Residue arm: must not move.
module sub (output logic [31:0] o);
  parameter int D = 4;
  logic [31:0] c;
  generate
    if (1) begin : g
      assign #D c = 32'd10;
    end
  endgenerate
  assign o = c;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
