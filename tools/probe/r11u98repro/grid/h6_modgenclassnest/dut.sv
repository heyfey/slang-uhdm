// r11u98 h6 -- a class TWO generate blocks deep in a MODULE.
module sub ();
  generate
    if (1) begin : g1
      if (1) begin : g2
        class Cdeep; int x; endclass
      end
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
