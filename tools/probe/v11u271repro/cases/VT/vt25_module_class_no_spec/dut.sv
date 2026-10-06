// § tpUseShareModClassAbstains271v
module top;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp);
    T m;
    function T get(); T l; l = m; return l; endfunction
  endclass
  reg_c #(comp) h;
endmodule
