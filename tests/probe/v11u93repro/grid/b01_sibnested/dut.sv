module sub ();
  module bmod2 (input logic y, output logic [7:0] z);
    amod2 #(.W(8)) u_a (.x({8{y}}), .r(z));
  endmodule
  module amod2 #(parameter int W = 2) (input logic [W-1:0] x, output logic [W-1:0] r);
    assign r = ~x;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
