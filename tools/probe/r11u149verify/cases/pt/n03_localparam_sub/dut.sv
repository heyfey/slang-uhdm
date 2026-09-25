// § paramAliasBoundRefUnstored144
module sub #(parameter int X = 4) (output logic [7:0] o);
  typedef logic [X-1:0] my_t;
  localparam my_t Y = 2;
  assign o = Y;
endmodule
module dut(output logic [7:0] o);
  sub #(.X(5)) u(.o(o));
endmodule
