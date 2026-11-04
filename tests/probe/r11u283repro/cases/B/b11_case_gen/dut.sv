// § bindChildDisplayScopedNames283
module tgt (input logic [3:0] d, output logic [3:0] o); assign o = d; endmodule
module mon #(parameter int K = 1) (input logic [3:0] d);
  logic [3:0] y;
  case (K)
    1: begin : c1
      assign y = d;
    end
    default: begin : cd
      assign y = 0;
    end
  endcase
endmodule
module dut (input logic [3:0] d, output logic [3:0] o);
  tgt u_t (.d(d), .o(o));
  bind tgt mon #(.K(1)) u_m (.d(d));
endmodule
