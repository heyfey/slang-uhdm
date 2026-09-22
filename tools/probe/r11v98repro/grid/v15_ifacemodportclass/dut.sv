// v15 -- an interface with a modport and a gen-block class.
interface ifc ();
  logic a, b;
  modport mp (input a, output b);
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
