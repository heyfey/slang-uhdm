// residue (sister ground, no law landed): a begin after a token paste in a macro body, golden column +3; see README
`define OPB(OP, FLAG) \
F_COPY: \
  if (!(FLAG)) begin
module top;
  localparam int F_COPY = 1, F_COMPARE = 2, NO_COPY = 4, NO_COMPARE = 8, DEF = 3;
  int x;
  function void f(int op);
    case (op)
      `OPB(COPY, DEF)
        x = 1;
      end
      `OPB(COMPARE, DEF)
        x = 2;
      end
    endcase
  endfunction
endmodule
