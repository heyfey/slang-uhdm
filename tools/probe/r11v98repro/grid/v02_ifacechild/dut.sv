// v02 -- a NON-SIMPLE interface (holds a child instance) with a gen-block class.
module leaf (); wire [31:0] w = 32'd1; endmodule
interface ifc ();
  leaf u_l ();
  generate
    if (1) begin : g
      class C; int x; endclass
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = 32'd0;
endmodule
