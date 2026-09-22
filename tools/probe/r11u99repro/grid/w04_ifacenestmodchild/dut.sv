// non-simple interface whose child is a MODULE, with a body class
module leaf (); wire [31:0] w = 32'd1; endmodule
interface outer ();
  leaf u_l ();
  class Zbody; int z; endclass
endinterface
module dut (output logic [31:0] o);
  outer u_o ();
  assign o = 32'd0;
endmodule
