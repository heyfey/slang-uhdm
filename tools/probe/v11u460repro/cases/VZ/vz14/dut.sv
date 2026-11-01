// § clsArrPatBasedLitElemW460 (associative and enum element)
typedef enum logic [1:0] {A, B, C2} e_t;
class C;
  int as[int] = '{1: 'h3, 2: 'h4};
  e_t ea[] = '{A, B};
  int dflt[2] = '{default: 'h7};
endclass
module top;
  initial begin C c; c = new; end
endmodule
