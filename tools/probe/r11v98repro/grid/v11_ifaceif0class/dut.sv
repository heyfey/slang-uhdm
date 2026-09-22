// v11 -- an UNTAKEN if(0) generate arm in an INTERFACE, carrying a class.
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (0) begin : g
      class Cgone; int x; endclass
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = 32'd0;
endmodule
