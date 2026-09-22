// v26 -- a module with a gen-block class that is NEVER instantiated.
module orphan ();
  generate
    if (1) begin : g
      class Corph; int x; endclass
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  assign o = 32'd0;
endmodule
