// § interconnectNetNone412
module sub(interconnect [3:0] x);
endmodule
module top;
  interconnect [3:0] bus;
  sub u(.x(bus));
endmodule
