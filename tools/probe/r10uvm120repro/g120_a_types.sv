// r10uvm120 arm a: the PARAMETER TYPE face of a bare parameter read that is
// the whole returned expression of a package-homed function.
package p120a;
  parameter string    s_p = "hello";
  parameter int       i_p = 42;
  parameter           u_p = 7;
  parameter byte      b_p = 8'sd5;
  parameter bit [3:0] v_p = 4'hA;
  parameter real      r_p = 1.5;
  typedef logic [7:0] my_t;
  parameter my_t      t_p = 8'hFF;
  localparam int      l_p = 99;
  parameter string    e_p = "";

  function string     f_str();  return s_p; endfunction
  function int        f_int();  return i_p; endfunction
  function int        f_unt();  return u_p; endfunction
  function byte       f_byt();  return b_p; endfunction
  function bit [3:0]  f_vec();  return v_p; endfunction
  function real       f_real(); return r_p; endfunction
  function my_t       f_typ();  return t_p; endfunction
  function int        f_loc();  return l_p; endfunction
  function string     f_emp();  return e_p; endfunction
endpackage

module top120a;
  initial $display(p120a::f_str(), p120a::f_int(), p120a::f_unt(),
                   p120a::f_byt(), p120a::f_vec(), p120a::f_real(),
                   p120a::f_typ(), p120a::f_loc(), p120a::f_emp());
endmodule
