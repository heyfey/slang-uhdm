// § anonUnpackedStructSlotEnd402
module child;
  struct {
    int a;
    bit [3:0] b;
  } s;
endmodule
module top;
  child c();
endmodule
