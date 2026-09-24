// v19 -- an INTERFACE with nested generate blocks carrying Zdeep and Adeep.
interface ifc ();
  generate
    if (1) begin : g1
      class Zdeep; int z; endclass
      if (1) begin : g2
        class Adeep; int a; endclass
      end
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = 32'd0;
endmodule
