// r11u98 h5 -- a MODULE body class Zbody and a gen-block class Agen: name order across homes.
module sub ();
  class Zbody; int z; endclass
  generate
    if (1) begin : g
      class Agen; int a; endclass
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
