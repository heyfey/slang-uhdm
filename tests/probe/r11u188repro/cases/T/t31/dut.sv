// § tpOwnTsAtHeaderDefault188 (the class_defn listing reads the header default, not the first specialization's override)
class C4 #(type TP = int);
  function void f();
    TP  z_typaram;
    int z_written;
    z_written = z_typaram;
  endfunction
  function TP r_tp(); r_tp = 0; endfunction
endclass
module m4_mod;
  C4 #(int) c4;
  initial c4 = new();
endmodule
