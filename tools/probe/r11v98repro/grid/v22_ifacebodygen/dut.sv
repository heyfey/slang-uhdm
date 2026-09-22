// v22 -- an INTERFACE with a body class Zbody and a gen-block class Agen.
interface ifc ();
  class Zbody; int z; endclass
  generate
    if (1) begin : g
      class Agen; int a; endclass
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = 32'd0;
endmodule
