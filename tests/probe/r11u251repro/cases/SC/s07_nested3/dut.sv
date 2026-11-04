// § ppStrEndNotTokStart251
`define Q3(F, P, T) \
  do begin \
    P.set(`"F`"); \
    P.hdr(`"F`", 1, `"T``(string)`"); \
  end while(0)
`define A2(F, P) \
   `Q3(F, P, da)
`define FLD(ARG) \
  begin \
    if (1) begin \
      `A2(ARG, p); \
    end \
  end
class pr; function void set(string s); endfunction function void hdr(string a, int b, string c); endfunction endclass
module top; pr p = new; initial `FLD(abstractions) endmodule
