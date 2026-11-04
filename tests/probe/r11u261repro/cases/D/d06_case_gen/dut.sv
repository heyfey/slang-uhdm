// § genChildParentAtBirth261
module leaf (input logic [31:0] d, output logic [15:0] o);
  assign o = d[31:16];
endmodule
module mid #(parameter int K = 1) (input logic [31:0] d, output logic [15:0] o);
  case (K)
    0: begin : g0 assign o = '0; end
    default: begin : gd leaf l (.d(d), .o(o)); end
  endcase
endmodule
module top;
  logic [31:0] d; logic [15:0] o;
  mid m (.d(d), .o(o));
endmodule
