// § implicitNetAfterForwarded460 (control: no forwarded block)
module child(input logic a, output logic b); assign b = a; endmodule
module top;
  logic x;
  child u(.a(x), .b(y));
endmodule
