// § macroIfaceRangeSelBaseTok256 (an interface path through a struct member, a part select in a macro body)
`define wr(FIF, L) \
  assign FIF.s.f[L+:2] = x;
typedef struct packed { logic [7:0] f; logic g; } s_t;
interface bif; s_t s; endinterface
module m(bif bit_field_if); logic [1:0] x;
  `wr(bit_field_if, 2)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule
