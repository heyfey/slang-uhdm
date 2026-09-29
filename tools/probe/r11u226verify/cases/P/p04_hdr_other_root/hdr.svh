`define HCALL(CB,METHOD) \
  begin \
    if (CB != null) begin \
      CB.METHOD; \
    end \
  end
`define HNAME(CB) CB.get_name()
