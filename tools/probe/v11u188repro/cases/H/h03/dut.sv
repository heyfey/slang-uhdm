// § tpOwnTsAtHeaderDefault188

class C4 #(type TP = int);
  function void f();
    TP  z_typaram;
    int z_written;
    z_written = z_typaram;
  endfunction
  function TP r_tp(); r_tp = 0; endfunction
endclass
module m4_mod;
  C4 #(int) a;
  C4 #(byte) b;
  initial begin a = new(); b = new(); end
endmodule
