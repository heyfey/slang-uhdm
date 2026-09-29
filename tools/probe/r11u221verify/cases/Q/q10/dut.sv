// § ndaRangeQueryFold216 — net initializers querying a localparam with a range, a typedef-typed variable, and a net inside a generate-case block
module dut #(parameter int S = 0) (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  localparam logic [9:3] LP = 7'd5;
  typedef logic [0:4] r_t;
  r_t rv;
  wire [7:0] w1 = $left(LP);
  wire [7:0] w2 = $right(rv);
  case (S)
    0: begin : c0
      logic [14:8] cn;
      wire [7:0] w3 = $high(cn);
      assign o3 = w3;
    end
    default: begin : cd assign o3 = 8'd0; end
  endcase
  assign o1 = w1;
  assign o2 = w2;
endmodule
