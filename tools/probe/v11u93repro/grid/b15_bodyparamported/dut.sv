module sub ();
  module innermod (output logic [7:0] r);
    parameter int P = 5;
    localparam int Q = P + 1;
    assign r = Q;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
