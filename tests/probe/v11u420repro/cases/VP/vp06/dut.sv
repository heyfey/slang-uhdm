// § ansiNoDirNetPortUntyped420
module child(wire [3:0] b);
endmodule
module top;
  wire [3:0] x;
  child u(.b(x));
endmodule
