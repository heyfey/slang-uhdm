module sub(input logic [31:0] i, output logic [31:0] o);
  localparam type my_t = struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; };
  my_t s;
  my_t [1:0] arr;
  assign s = '0;
  assign arr = '0;
  assign o = s.a + arr[0].a + i;
endmodule
module top(input logic [31:0] i, output logic [31:0] o);
  sub u(.i(i), .o(o));
endmodule
