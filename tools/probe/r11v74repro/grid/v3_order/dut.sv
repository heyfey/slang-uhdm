// v11u74 v3 — LAW B, DECLARATION ORDER AND UNNAMED SCOPES.  slang's
// Scope::find is order-blind; a name bind in the producer may not be.  Also
// an UNNAMED enclosing generate block as the namesake home, and a namesake
// that exists only in a NON-elaborated (false) gen-if arm.
module dut (output logic [31:0] o);
  for (genvar i = 0; i < 1; i = i + 1) begin : ga
    logic [31:0] later;       // namesake declared BELOW the generate block
    assign later = 32'd1;
    if (1) begin              // UNNAMED enclosing gen-if
      logic [31:0] unn;
      if (1) begin : gdeep
        logic [31:0] unn;     // target here, namesake in the UNNAMED block
        assign unn = 32'd2;
      end
      assign unn = 32'd3;     // target IS the unnamed block's own local
    end
    logic [31:0] falsearm;
    assign falsearm = 32'd4;  // namesake lives only in a FALSE gen-if arm
  end
  if (0) begin : gdead
    logic [31:0] falsearm;
  end
  logic [31:0] later;         // the LATE module-body declaration
  assign later = 32'd9;
  assign o = ga[0].later ^ ga[0].falsearm ^ later;
endmodule
