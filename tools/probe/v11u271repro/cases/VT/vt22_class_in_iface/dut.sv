// § tpUseSharesOwnTs271
interface ifc ();
  class obj; endclass
  class reg_c #(type T = obj);
    T m;
    function T get(); T l; l = m; return l; endfunction
  endclass
  class sb extends obj;
    typedef reg_c #(sb) type_id;
  endclass
  sb s;
endinterface
module top;
  ifc u_i ();
endmodule
