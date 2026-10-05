// § ppStrEndNotTokStart251
`define Q3(F, P, T) \
  do begin \
    P.set(`"F`"); \
    P.hdr(`"F`", 1, `"T``(string)`"); \
  end while(0);
`define A2(F, P) \
   `Q3(F, P, da)
`define QDA(TYPE,ARG,FLAG) \
  begin \
    if (FLAG) begin \
      `A2(ARG, c.p) \
    end \
  end
`define FQ(ARG,FLAG) \
  `QDA(QUEUE,ARG,FLAG)
class pr; function void set(string s); endfunction function void hdr(string a, int b, string c); endfunction endclass
class cc; pr p = new; endclass
module top; cc c = new; initial `FQ(abstractions, 1) endmodule
