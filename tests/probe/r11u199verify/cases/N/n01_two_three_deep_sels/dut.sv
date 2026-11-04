// § nestedDefChainName193 § nestChainSelects193v
module sub (input logic [7:0] x);
  module mid (input logic [7:0] a, output logic [7:0] m);
    module inner (input logic [7:0] b, output logic [3:0] q);
      logic [7:0] t;
      assign t = b;
      assign q = t[5:2] ^ {3'b0, t[1]};
    endmodule
    logic [7:0] u;
    assign u = a;
    assign m = {u[3:0], u[7:4]};
  endmodule
  wire [7:0] w = x;
  wire [3:0] v = w[3:0];
endmodule
module dut (input logic [7:0] x, output logic [3:0] o);
  sub u_s (.x(x));
  assign o = x[3:0];
endmodule
