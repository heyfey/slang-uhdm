// v119 arm F — THE FENCE CONTROLS.  Nothing here may move.
package pk_f;
  // a USER function named randomize, reached through a package
  function automatic int unsigned randomize(int unsigned v_f);
    return v_f + 1;
  endfunction
endpackage

class it_f;
  rand int unsigned f_a;
  rand int unsigned f_b;
  int unsigned f_plain;
  function int unsigned do_f(int unsigned k_f);
    return k_f;
  endfunction
  function int unsigned noarg_f();
    return 7;
  endfunction
endclass

class drv_f;
  it_f r_f;
  int unsigned out_f;
  rand int unsigned s_a;
  rand int unsigned s_b;
  task run_f();
    int unsigned l_x, l_y;
    // uvm116's SCOPE form, with and without a with-block
    if (!randomize() with { s_a > 1; }) out_f = 1;
    if (!randomize(s_a)) out_f = 2;
    if (!randomize(s_a, s_b) with { s_a > 2; }) out_f = 3;
    // std::randomize, with and without a with-block
    if (!std::randomize(l_x)) out_f = 4;
    if (!std::randomize(l_x, l_y) with { l_x > 3; }) out_f = 5;
    // the MEMBER form with NO with-block, four arities
    if (!r_f.randomize()) out_f = 6;
    if (!r_f.randomize(f_a)) out_f = 7;
    if (!r_f.randomize(f_a, f_b)) out_f = 8;
    if (!r_f.randomize(null)) out_f = 9;
    // rand_mode and constraint_mode BESIDE
    r_f.f_a.rand_mode(0);
    r_f.rand_mode(1);
    r_f.constraint_mode(0);
    // a NON-randomize dotted call, with and without arguments
    out_f = r_f.do_f(5);
    out_f = r_f.noarg_f();
    // a user function named randomize through a package
    out_f = pk_f::randomize(3);
  endtask
endclass

module top_f2;
  drv_f d_f;
  initial begin
    d_f = new();
    d_f.run_f();
  end
endmodule
