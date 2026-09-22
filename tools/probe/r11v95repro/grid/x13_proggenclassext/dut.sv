// v11u93 x13 -- a generate-block class EXTENDING a body class.
program prg ();
  class Base; int b; endclass
  generate
    if (1) begin : g
      class Derived extends Base; int d; endclass
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
