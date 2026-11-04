// § pureVirtFormalSignKwTrim247
`define PROTO(T) pure virtual function void setp(T prec);
virtual class base;
  `PROTO(int unsigned)
  pure virtual function void put(input int unsigned a, ref int signed b);
endclass
module top;
  base x;
endmodule
