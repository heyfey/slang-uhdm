`define STR(__x) `"__x`"
`define A0(__n) $display("A0", `STR(__n));
`define A1(__n) $display("A1", \
    `STR(__n));
`define A3(__n) $display("A3",   \
`STR(__n));
`define A9(__n) $display("A9",         \
         `STR(__n));
`define A2C(__n) $display("A2C", \
  "x", \
   `STR(__n));
`define ATAB(__n) $display("ATAB",	\
  `STR(__n));
module top;
  initial begin
    `A0(N0)
    `A1(N1)
    `A3(N3)
    `A9(N9)
    `A2C(N2C)
    `ATAB(NTAB)
  end
endmodule
