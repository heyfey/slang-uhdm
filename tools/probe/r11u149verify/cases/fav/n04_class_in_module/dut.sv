// § foreachArrayPlaceholderFile140
module dut;
  class c;
    byte b[4];
    function void z();
      foreach (b[n]) b[n] = 0;
    endfunction
  endclass
endmodule
