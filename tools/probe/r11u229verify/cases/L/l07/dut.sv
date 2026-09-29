// § hpLvSelIdxNamesByPath224 (the path through an interface port)
interface bus_if;
  typedef struct { logic [3:0] arr [4]; } s_t;
  s_t s;
endinterface
module m(bus_if b, input int i, input logic [1:0] d);
  always_comb b.s.arr[i][1:0] = d;
endmodule
module top(input int i, input logic [1:0] d);
  bus_if u();
  m mm(.b(u), .i(i), .d(d));
endmodule
