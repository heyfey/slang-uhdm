interface ifc; logic v; endinterface
module sub ();
  module innermod (output logic r);
    ifc i0 ();
    assign i0.v = 1'b1;
    assign r = i0.v;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
