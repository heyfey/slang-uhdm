// § sysCallArgRefScopedName303
module dut #(parameter int N = 16) (input logic [7:0] i, output logic [7:0] o);
  case ($clog2(N))
    4: begin : g4 assign o = i; end
    default: begin : gd assign o = ~i; end
  endcase
endmodule
