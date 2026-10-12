// § sysCallArgRefScopedName303
module dut #(parameter int N = 16) (input logic [7:0] i, output logic [7:0] o);
  if ($clog2(N) > 2) begin : g
    assign o = i;
  end
endmodule
