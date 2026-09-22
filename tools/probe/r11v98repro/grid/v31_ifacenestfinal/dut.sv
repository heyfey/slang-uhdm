// v31 -- a NON-SIMPLE interface (child INTERFACE instance) with a final in a generate block.
interface inner (); wire [31:0] w = 32'd1; endinterface
interface outer ();
  inner u_in ();
  generate
    if (1) begin : g
      final begin
        $display("bye");
      end
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  outer u_o ();
  assign o = 32'd0;
endmodule
