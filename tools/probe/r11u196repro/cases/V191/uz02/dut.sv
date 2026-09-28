// § elabCaConstLhsSized191: a module-local binary parameter wider than the LHS (truncated) and a decimal one (unchanged size)
module m(output logic [3:0] a, output logic [7:0] b);
  localparam logic [7:0] P = 8'b1010_0101;
  localparam int D = 9;
  assign a = P;
  assign b = D;
endmodule
module top(output logic [3:0] o1, output logic [7:0] o2);
  m u(.a(o1), .b(o2));
endmodule
