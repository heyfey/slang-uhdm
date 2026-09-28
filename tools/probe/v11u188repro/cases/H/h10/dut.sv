// § tpOwnTsAtHeaderDefault188

class C4 #(type TP = bit);
  function void f();
    TP  z_typaram;
    int z_written;
    z_written = z_typaram;
  endfunction
  function TP r_tp(); r_tp = 0; endfunction
endclass
module m4_mod;
  C4 #(bit) c4;
  C4 #(bit) c6;
  initial c4 = new();
endmodule
