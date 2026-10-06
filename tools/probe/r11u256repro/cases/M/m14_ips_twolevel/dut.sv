// § macroIfaceRangeSelBaseTok256 (a two-level member path (struct member of an interface signal) in a macro body)
`define conn(FIF, LSB) \
  assign  FIF.st.read_data[LSB+:4] = x;
typedef struct packed { logic [7:0] read_data; } s_t;
interface bif; s_t st; endinterface
module m(bif bi); logic [3:0] x;
  `conn(bi, 4)
endmodule
module top; bif b(); m u(.bi(b)); endmodule
