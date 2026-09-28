// § nestedDefChainName193 § nestChainSelects193v
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module sub (input logic [7:0] x);
  module inner (input logic [7:0] b, input logic [2:0] k, output logic [7:0] q);
    logic [7:0] t;
    s_t s;
    logic [7:0] arr [4];
    assign t = b;
    assign s = b;
    assign arr[0] = b;
    assign arr[1] = t;
    assign arr[2] = '0;
    assign arr[3] = t;
    assign q = {t[k], t[6:5], t[k+:2], t[7-:2], s.a[1], arr[k[1:0]][0]};
  endmodule
  logic [7:0] w;
  assign w = x;
endmodule
module dut (input logic [7:0] x, output logic [7:0] o);
  sub u_s (.x(x));
  assign o = x;
endmodule
