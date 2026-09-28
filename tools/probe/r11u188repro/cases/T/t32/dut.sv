// § tpOwnTsAtHeaderDefault188 (control: the override differs from the default)
class C4 #(type TP = int);
  function void f();
    TP  z_typaram;
    int z_written;
    z_written = z_typaram;
  endfunction
endclass
module m4_mod;
  C4 #(byte) c4;
  initial c4 = new();
endmodule
