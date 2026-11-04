// § ppMacroBodyLines160
`define ASRT(name, cond, msg) \
  always_comb begin \
    name = (cond); \
    if (!name) $display(`"msg`"); \
  end
module top (input logic a, input logic b, output logic ok);
  `ASRT(ok, a &&
             b,
        bad_thing)
endmodule
