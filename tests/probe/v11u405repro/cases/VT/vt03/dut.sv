// § typenameKwIsString405
module top();
  localparam string s = $typename(integer);
  initial $display("%s", s);
endmodule
