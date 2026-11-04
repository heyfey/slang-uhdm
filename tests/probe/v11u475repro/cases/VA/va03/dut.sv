// § addOperandConstMint475
// int-typed origins in a module and a child override
module sub #(parameter int PA = 5, parameter int PC = PA + 1) (output logic [31:0] y);
  assign y = PC;
endmodule
module top(output logic [31:0] y1, y2);
  sub #(.PA(6'd9)) u1(y1);
  sub u2(y2);
endmodule
