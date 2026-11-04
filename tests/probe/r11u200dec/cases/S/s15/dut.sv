`define T(typ) \
    if (1) begin \
        typ x = -1; \
        function automatic typ f; \
            input integer x; \
            f = x; \
        endfunction \
        logic [127:0] c = f(-1); \
    end
module s15;
  `T(int )
  `T(int signed)
  `T(int unsigned)
  `T(integer )
  `T(integer signed)
  `T(integer unsigned)
  `T(shortint )
  `T(shortint signed)
  `T(shortint unsigned)
  `T(longint )
  `T(longint signed)
  `T(longint unsigned)
  `T(byte )
  `T(byte signed)
  `T(byte unsigned)
  `T(bit )
  `T(bit signed)
  `T(bit unsigned)
  `T(logic )
  `T(logic signed)
  `T(logic unsigned)
  `T(reg )
  `T(reg signed)
  `T(reg unsigned)
endmodule
