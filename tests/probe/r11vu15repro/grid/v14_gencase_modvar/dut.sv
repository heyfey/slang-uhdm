module top #(parameter int P = 1) (input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  case (P)
    1: begin : gb
      logic [31:0] loc;
      assign mv  = a;
      assign loc = mv;
    end
    default: begin : gd
      assign mv = 32'd0;
    end
  endcase
  assign o = mv;
endmodule
