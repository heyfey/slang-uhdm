// v12 — chain in a module instantiated inside a GENERATE FOR loop.
module child #(
    parameter type a_t = logic [1:0],
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
module dut ( input logic [1:0] i, output logic [1:0] o );
  genvar g;
  generate for (g = 0; g < 2; g++) begin : gb
    child #() u ( .i(i), .o(o[g]) );
  end endgenerate
endmodule
