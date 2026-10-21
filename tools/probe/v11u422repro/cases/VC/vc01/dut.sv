// § classChandleTdPropBareLogicVar422
// a class property typed by an alias of a chandle typedef
typedef chandle ch_t;
typedef ch_t ch2_t;
class C;
  ch2_t h;
  ch_t k;
endclass
module top;
  C c = new;
endmodule
