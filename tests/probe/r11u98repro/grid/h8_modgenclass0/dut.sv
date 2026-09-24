// r11u98 h8 -- a class in an UNTAKEN if(0) generate arm in a MODULE.
module sub ();
  generate
    if (0) begin : g
      class Cgone; int x; endclass
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
