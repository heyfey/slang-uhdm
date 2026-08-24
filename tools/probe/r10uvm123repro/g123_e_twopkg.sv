// r10uvm123 arm E — TWO packages, the second WILDCARD-IMPORTS the first (the
// import-clone topology uvm114 measured), with a class in the SECOND package
// casting the FIRST's vector typedefs, and a class in the first casting its own.
`define E_Wid123 20
package elm123_root;
  typedef bit   [`E_Wid123-1:0] LEAF_bt;
  typedef logic [`E_Wid123-1:0] leaf_LT;
  typedef enum bit [1:0] { E_A123 = 2'd0, E_B123 = 2'd3 } leaf_et;
  class ElmRoot123;
    LEAF_bt r_b;
    function int rc(int k);
      r_b = LEAF_bt'(k);
      return 1;
    endfunction
  endclass
endpackage

package elm123_leafpkg;
  import elm123_root::*;
  class ElmLeaf123;
    LEAF_bt l_b;
    leaf_LT l_l;
    leaf_et l_e;
    extern function int lc(int k);
  endclass
  function int ElmLeaf123::lc(int k);
    l_b = LEAF_bt'(k);
    l_l = leaf_LT'(k);
    l_e = leaf_et'(k);
    return 8;
  endfunction
endpackage

module elm123_top;
  import elm123_leafpkg::*;
  ElmLeaf123 e;
  initial e = new();
endmodule
