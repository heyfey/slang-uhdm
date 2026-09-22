// LAW A decline zone: a nested module with an INTERFACE port
interface ifc; logic v; endinterface
module sub ();
  module innermod (ifc b);
    assign b.v = 1'b1;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
