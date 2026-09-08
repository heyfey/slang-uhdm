// vJ — a separated export in an interface that also carries a modport, a
// generate block with its own function, and a second interface whose function
// has the SAME bare name but no export.
interface v216_if_j (input logic clk);
  export "DPI-C" function ej_one;
  logic a, b;
  modport mp (input a, output b);
  function automatic int plain_j(int x);
    return x + 1;
  endfunction
  for (genvar gi = 0; gi < 2; gi++) begin : gblk
    function automatic int gen_fn(int x);
      return x + gi;
    endfunction
  end
  function automatic int ej_one(int x);
    return x + 2;
  endfunction
endinterface
interface v216_if_j2;
  function automatic int ej_one(int x);
    return x + 9;
  endfunction
endinterface
