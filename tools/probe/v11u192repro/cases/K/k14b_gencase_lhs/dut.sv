// § psBoundPaOwnerName192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] q);
  case (W)
    4: begin : gc
      assign q[31:W] = {x[W:0]};
    end
    default: begin : gd
      assign q = x;
    end
  endcase
endmodule
