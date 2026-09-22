// v27 -- a NON-SIMPLE interface (holds a child INTERFACE instance) with a gen-block class.
interface inner (); wire [31:0] w = 32'd1; endinterface
interface outer ();
  inner u_in ();
  generate
    if (1) begin : g
      class Cgen; int x; endclass
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  outer u_o ();
  assign o = 32'd0;
endmodule
