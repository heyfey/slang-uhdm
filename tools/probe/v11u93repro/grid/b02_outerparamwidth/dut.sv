module sub #(parameter int W = 4) ();
  module innermod (input logic [W-1:0] a, output logic y);
    assign y = ^a;
  endmodule
  wire [W-1:0] q = '0;
endmodule
module dut (output logic [31:0] o);
  sub #(.W(8)) u_s ();
  assign o = 32'd0;
endmodule
