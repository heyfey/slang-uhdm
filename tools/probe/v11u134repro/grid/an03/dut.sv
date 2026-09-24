// § anonMemberRefChainName134
module sub(input struct packed { struct packed { logic a, b; } in2; logic c; } pin, output logic o);
  assign o = pin.in2.a ^ pin.c;
endmodule
module top(input logic x, output logic o);
  sub s(.pin({x, x, x}), .o(o));
endmodule
