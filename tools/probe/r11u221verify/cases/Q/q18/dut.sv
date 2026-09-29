// § rqParamOpBoundAtCall216v (with § genScopeRangeQueryFold216 § ndaRangeQueryFold216) — a parameter queried in a child instantiated twice with overrides of the bound, both in a gen-case and in a net initializer, and a parameter with a plain literal bound as a control
module sub #(parameter int W = 2, parameter logic [W+1:0] P = 0, parameter logic [5:2] Q = 0) (output logic [7:0] y, output logic [7:0] z, output logic [7:0] q);
  wire [7:0] nz = $left(P);
  case (W)
    2: begin : c2 assign y = $high(P); end
    default: begin : cd assign y = $low(P); end
  endcase
  assign z = nz;
  assign q = $high(Q);
endmodule
module dut (output logic [7:0] y1, output logic [7:0] y2, output logic [7:0] z1, output logic [7:0] z2, output logic [7:0] q1);
  sub #(.W(2)) u1 (.y(y1), .z(z1), .q(q1));
  sub #(.W(4)) u2 (.y(y2), .z(z2), .q());
endmodule
