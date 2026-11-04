// § nonAnsiArrayNetAtHeader155
module dut(\a$b , o);
  input logic [1:0] \a$b [2];
  output logic [1:0] o;
  assign o = \a$b [0] | \a$b [1];
endmodule
