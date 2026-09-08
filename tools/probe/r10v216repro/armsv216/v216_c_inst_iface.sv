// vC — an INSTANTIATED interface with a separated export (slang resolves the
// export itself here; only the POSITION half of the law is exercised).
interface v216_if_c;
  export "DPI-C" function ec_one;
  function automatic int plain_c(int x);
    return x + 1;
  endfunction
  function automatic int ec_one(int x);
    return x + 2;
  endfunction
endinterface
module v216_top_c;
  v216_if_c u_if();
  initial begin
    if (u_if.plain_c(1) == 0) $display("x");
  end
endmodule
