module top(input logic [63:0] a, input logic [63:0] b, input logic [1:0] s, output logic [63:0] o);
  logic [63:0] p;
  always_comb begin : blk
    p = a;
    case (s)
      0: p[3:0] = b[3:0];
      1: p[7:4] = b[7:4];
      default: p[11:8] = b[11:8];
    endcase
    o = p;
  end
endmodule
