// v07 -- a PARAMETERIZED class inside a MODULE's generate block.
module sub ();
  generate
    if (1) begin : g
      class Pgen #(int N = 1); int p; endclass
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
