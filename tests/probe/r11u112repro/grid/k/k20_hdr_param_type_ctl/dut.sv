module top #(parameter type my_t = struct packed { logic [31:0] a; logic [7:0] c; })(input logic clk, output logic [31:0] o);
  my_t s;
  my_t [1:0] arr;
  assign s = '0;
  assign arr = '0;
  assign o = s.a + arr[0].a;
endmodule
