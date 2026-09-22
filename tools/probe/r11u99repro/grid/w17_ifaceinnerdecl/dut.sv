// a MODULE declared inside an INTERFACE (which is not a stop point)
interface outer ();
  wire [31:0] w = 32'd1;
  module innermod ();
    class Ciface; int c; endclass
  endmodule
endinterface
module dut (output logic [31:0] o);
  outer u_o ();
  assign o = 32'd0;
endmodule
