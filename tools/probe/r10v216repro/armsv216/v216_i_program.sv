// vI — a PROGRAM block with a separated export.
program v216_prg_i;
  export "DPI-C" function ei_one;
  function automatic int plain_i(int x);
    return x + 1;
  endfunction
  function automatic int ei_one(int x);
    return x + 2;
  endfunction
  initial begin
    if (plain_i(1) == 0) $display("x");
  end
endprogram
