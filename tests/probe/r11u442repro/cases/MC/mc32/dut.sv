// § unitClassTdEndAtDim442
class C;
endclass
typedef C c_t;
module top;
  c_t h = new;
endmodule
module m2;
  c_t a [4];
endmodule
