// r10uvm68 arm a1 — WHERE does a NAMED (typedef'd) `int` lose vpiSigned?
// Every cell is the SAME type reached two ways: written `int` (the `p_` cells)
// and through a typedef NAME (the `t_` cells).  Cell names are unique across
// the whole arm so a census can key on them.
typedef int myint_t;

class C1;
  int              p_prop;        // class property, written
  myint_t          t_prop;        // class property, named
  function int f_ret_p();  f_ret_p = 0; endfunction        // return, written
  function myint_t f_ret_t();  f_ret_t = 0; endfunction    // return, named
  function void m1();
    int      p_loc;               // method body local, written
    myint_t  t_loc;               // method body local, named
    int      p_loci = 3;          // ... with initialiser
    myint_t  t_loci = 4;
    begin : blk
      int     p_blk = 5;          // begin-block local + init, written
      myint_t t_blk = 6;          // begin-block local + init, named
      p_blk = t_blk;
    end
    p_loc = t_loc; p_loci = t_loci;
  endfunction
  task m2(int p_io, myint_t t_io); // formals
    int     p_tsk;
    myint_t t_tsk;
    p_tsk = t_tsk;
  endtask
endclass

module m1_mod;
  int     p_mvar;                 // module var, written
  myint_t t_mvar;                 // module var, named
  function int f_mret_p(); f_mret_p = 0; endfunction
  function myint_t f_mret_t(); f_mret_t = 0; endfunction
  function void mf();
    int     p_mfloc;
    myint_t t_mfloc;
    p_mfloc = t_mfloc;
  endfunction
  initial begin
    int     p_ini = 1;
    myint_t t_ini = 2;
    for (int p_for = 0; p_for < 2; p_for++) ;
    for (myint_t t_for = 0; t_for < 2; t_for++) ;
    p_ini = t_ini;
  end
endmodule
