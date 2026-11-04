// § oobUnitClsTdUnsupported410
class C;
  typedef logic [7:0] b_t;
  extern task t(b_t a);
endclass
task C::t(b_t a);
  b_t loc;
  loc = a;
endtask
module top; C c = new; endmodule
