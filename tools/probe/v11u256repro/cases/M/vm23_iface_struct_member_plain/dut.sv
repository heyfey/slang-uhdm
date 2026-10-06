// § macroIfaceRangeSelBaseTok256 (the plain-source twin of vm22: no macro, the law does not run)
typedef struct packed { logic [7:0] f; logic g; } s_t;
interface bif; s_t s; endinterface
module m(bif bit_field_if); logic [1:0] x;
  assign bit_field_if.s.f[2+:2] = x;
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule
