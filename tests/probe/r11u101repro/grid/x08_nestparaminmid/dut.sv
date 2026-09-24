// LAW A x B4: a PARAMETERIZED module one level deep holding a portless one below it
module sub ();
  module mid #(parameter int P = 1) ();
    module deep ();
      wire d;
    endmodule
    wire m;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
