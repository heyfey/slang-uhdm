// LAW A x LAW B: two outers, each with a same-named PORTED nested module
module amod ();
  module innermod (output logic [31:0] ra);
    assign ra = 32'd1;
  endmodule
endmodule
module bmod ();
  module innermod (input logic [7:0] ib, output logic [7:0] rb);
    assign rb = ib;
  endmodule
endmodule
module dut (output logic [31:0] o);
  amod u_a ();
  bmod u_b ();
  assign o = 32'd0;
endmodule
