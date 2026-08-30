package Pk_Self;
  class SelfNu #(type TT = int);
    SelfNu#(int) n05_selftyped;
  endclass
endpackage
module M_self;
  Pk_Self::SelfNu#(int) u_sn;
endmodule
