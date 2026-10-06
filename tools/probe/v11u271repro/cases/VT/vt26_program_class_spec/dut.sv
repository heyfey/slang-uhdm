// § tpUseShareModClassAbstains271v
program prg;
  class obj; endclass
  class comp extends obj; endclass
  class reg_c #(type T = comp);
    T m;
    function T get(); T l; l = m; return l; endfunction
  endclass
  class sbase extends comp;
    typedef reg_c #(sbase) type_id;
  endclass
  sbase s;
endprogram
module top;
  prg p ();
endmodule
