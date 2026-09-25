// § pasteChainRunning160v
`define CALL(n) f_``n(2)
module top (output logic [3:0] o);
  function automatic logic [3:0] f_inc(logic [3:0] v); return v + 1; endfunction
  assign o = `CALL(inc) ^ 4'h1;
endmodule
