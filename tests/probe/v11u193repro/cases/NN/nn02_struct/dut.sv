// § nestedDefChainName193
module sub ();
  module inner (input logic [3:0] i, output logic [3:0] q);
    typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
    s_t s;
    assign s = i;
    assign q = {s.a, s.b};
  endmodule
  wire [3:0] w = 4'd1;
endmodule
module dut (output logic [3:0] o);
  sub u_s ();
  assign o = 4'd0;
endmodule
