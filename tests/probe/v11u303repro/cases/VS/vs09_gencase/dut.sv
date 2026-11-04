// § sysCallArgRefScopedName303
module dut #(parameter int N = 8) (input logic [7:0] i, output logic [7:0] o);
  case ($clog2(N))
    3: begin : g assign o = i; end
    default: begin : h assign o = ~i; end
  endcase
endmodule
