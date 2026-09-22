// M — a NESTED MODULE whose function shares the outer module's exported name.
module v216_mod_m;
  export "DPI-C" function em_one;
  function automatic int plain_m(int x);
    return x + 1;
  endfunction
  function automatic int em_one(int x);
    return x + 2;
  endfunction
  module v216_inner_m;
    function automatic int em_one(int x);
      return x + 9;
    endfunction
  endmodule
  v216_inner_m u_inner();
endmodule
