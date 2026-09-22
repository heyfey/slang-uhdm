// v10 -- an INTERFACE for-generate, bound 2, carrying a class.
interface ifc ();
  generate
    for (genvar i = 0; i < 2; i++) begin : gl
      class Cloop; int x; endclass
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = 32'd0;
endmodule
