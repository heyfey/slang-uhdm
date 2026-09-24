// LAW B (RV2): two outers, one same-named portless nested module each
module amod ();
  module innermod ();
    wire [31:0] ra = 32'd1;
  endmodule
endmodule
module bmod ();
  module innermod ();
    wire [7:0] rb = 8'd2;
  endmodule
endmodule
module dut (output logic [31:0] o);
  amod u_a ();
  bmod u_b ();
  assign o = 32'd0;
endmodule
