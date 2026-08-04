// UVM's uvm_object_globals.svh:49 `typedef logic signed [UVM_STREAMBITS-1:0]
// uvm_bitstream_t;` used as a formal's type.  Golden: the range bound stays an
// OPERATION in the def view and folds to a CONSTANT in the elab view; we do
// the opposite on both.
package pk;
  parameter W = 4096;
  typedef logic signed [W-1:0] bs_t;
  typedef logic [W-1:0] u_t;

  // A: typedef'd formal
  function string f(bs_t v);
    f = "x";
  endfunction

  // B: typedef'd package variable
  bs_t pv;

  // C: inline range on a formal (no typedef)
  function string g(logic [W-1:0] v);
    g = "y";
  endfunction

  // D: typedef'd class property + method local
  class C;
    bs_t p;
    function void m();
      u_t l;
      l = 0;
    endfunction
  endclass
endpackage

module top;
  import pk::*;
  bs_t mv;
  initial;
endmodule
