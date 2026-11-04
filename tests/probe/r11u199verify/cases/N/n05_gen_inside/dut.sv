// § nestedDefChainName193 § nestChainSelects193v
module sub (input logic [7:0] x);
  module inner (input logic [7:0] b, output logic [7:0] q);
    for (genvar i = 0; i < 2; i++) begin : g
      logic [3:0] n;
      assign n = b[i*4 +: 4];
      assign q[i*4 +: 4] = n;
    end
    if (1) begin : gi
      logic [7:0] z;
      assign z = b;
    end
  endmodule
  logic [7:0] w;
  assign w = x;
endmodule
module dut (input logic [7:0] x, output logic [7:0] o);
  sub u_s (.x(x));
  assign o = x;
endmodule
