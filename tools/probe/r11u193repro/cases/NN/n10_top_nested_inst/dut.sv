// § nestedDefChainName193
module dut (input logic [3:0] a, output logic [3:0] o);
  module leaf (input logic [3:0] x, output logic [3:0] y);
    logic [3:0] n;
    assign n = x ^ 4'hA;
    assign y = n;
  endmodule
  leaf u_l (.x(a), .y(o));
endmodule
