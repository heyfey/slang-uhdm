// § classChandleTdPropBareLogicVar422
// a chandle typedef declared in the class; rand-less local and protected properties
typedef chandle ch_t;
class C;
  local ch_t a;
  protected ch_t b;
  ch_t c [2];
endclass
module top;
  C c = new;
endmodule
