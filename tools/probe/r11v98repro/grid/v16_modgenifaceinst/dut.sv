// v16 -- an INTERFACE instantiated inside a MODULE's generate block.
interface ifc ();
  class Cif; int x; endclass
endinterface
module sub ();
  generate
    if (1) begin : g
      ifc u_i ();
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
