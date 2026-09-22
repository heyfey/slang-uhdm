// v28 -- a NON-SIMPLE interface (child INTERFACE instance) with a BODY class.
interface inner (); wire [31:0] w = 32'd1; endinterface
interface outer ();
  inner u_in ();
  class Zbody; int z; endclass
  class Abody; int a; endclass
endinterface
module dut (output logic [31:0] o);
  outer u_o ();
  assign o = 32'd0;
endmodule
