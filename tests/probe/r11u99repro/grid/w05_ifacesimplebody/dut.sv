// CONTROL: SIMPLE interface, body classes -- already right at the base
interface outer ();
  wire [31:0] w = 32'd1;
  class Zbody; int z; endclass
  class Abody; int a; endclass
endinterface
module dut (output logic [31:0] o);
  outer u_o ();
  assign o = 32'd0;
endmodule
