// non-simple interface whose child is an instance ARRAY, plus a gen-LOOP class
interface inner (); wire [31:0] w = 32'd1; endinterface
interface outer ();
  inner u_in [2] ();
  generate for (genvar i = 0; i < 2; i++) begin : gl
    class Cloop; int x; endclass
  end endgenerate
endinterface
module dut (output logic [31:0] o);
  outer u_o ();
  assign o = 32'd0;
endmodule
