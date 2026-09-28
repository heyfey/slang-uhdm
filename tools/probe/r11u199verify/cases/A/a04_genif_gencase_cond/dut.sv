// § psBoundPaOwnerName192
package p;
  parameter int unsigned W = 4;
endpackage
module sub import p::*; #(parameter int M = 1) (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  if (W > 2) begin : gi
    assign y1 = x[W:0];
  end else begin : ge
    assign y1 = x[W-1:0];
  end
  case (W)
    4: begin : c4
      assign y2 = x[W:1];
    end
    default: begin : cd
      assign y2 = '0;
    end
  endcase
  if (M == 1) begin : gm
    assign y3 = {x[31:W], 1'b0};
  end else begin : gn
    assign y3 = x;
  end
endmodule
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] z1, output logic [31:0] z2, output logic [31:0] z3);
  sub #(.M(1)) u1 (.x(x), .y1(y1), .y2(y2), .y3(y3));
  sub #(.M(2)) u2 (.x(x), .y1(z1), .y2(z2), .y3(z3));
endmodule
