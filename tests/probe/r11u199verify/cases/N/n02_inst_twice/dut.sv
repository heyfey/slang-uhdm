// § nestedDefChainName193 § nestChainSelects193v
module sub (input logic [7:0] x, output logic [3:0] y1, output logic [3:0] y2);
  module inner (input logic [7:0] b, output logic [3:0] q);
    logic [7:0] t;
    assign t = b;
    assign q = t[3:0];
  endmodule
  inner i1 (.b(x), .q(y1));
  inner i2 (.b(~x), .q(y2));
endmodule
module dut (input logic [7:0] x, output logic [3:0] y1, output logic [3:0] y2);
  sub u_s (.*);
endmodule
