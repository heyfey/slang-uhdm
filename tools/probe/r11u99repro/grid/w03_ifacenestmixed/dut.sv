// non-simple interface: BODY class Mbody + GEN class Cgen + BODY class Abody
interface inner (); wire [31:0] w = 32'd1; endinterface
interface outer ();
  inner u_in ();
  class Mbody; int m; endclass
  generate if (1) begin : g class Cgen; int x; endclass end endgenerate
  class Abody; int a; endclass
endinterface
module dut (output logic [31:0] o);
  outer u_o ();
  assign o = 32'd0;
endmodule
