// § fnRetLitRhsSharesDefConst273
interface ifc;
  function automatic int f(); return 21; endfunction
  int x;
  assign x = f();
endinterface
module dut (output int o);
  ifc i0();
  assign o = i0.x;
endmodule
