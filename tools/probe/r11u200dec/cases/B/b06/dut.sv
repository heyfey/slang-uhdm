module sub (input logic c, input logic [31:0] x, output logic [31:0] z);
  if ($bits(x[4:0]) != 5) begin : g
    assign z = 0;
  end else begin : h
    assign z = 1;
  end
endmodule
module top (input logic c, input logic [31:0] x, output logic [31:0] z);
  sub u (.*);
endmodule
