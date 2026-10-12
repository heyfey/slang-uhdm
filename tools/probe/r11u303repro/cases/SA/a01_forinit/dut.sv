// § sysCallArgRefScopedName303
module cell #(parameter int unsigned NC = 6) (input logic [7:0] i, output logic [7:0] o);
  localparam int unsigned MM = 1;
  for (genvar ce = $unsigned(MM); ce < NC; ce++) begin : g_ce
    assign o[ce] = i[ce];
  end
endmodule
module dut (input logic [7:0] i, output logic [7:0] o);
  cell #(.NC(6)) u (.i(i), .o(o));
endmodule
