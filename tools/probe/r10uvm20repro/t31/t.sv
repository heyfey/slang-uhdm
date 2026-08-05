// r10uvm20 t31 -- the two controls t30 could not answer:
//   (a) a subroutine FORMAL array (ref / input, all four kinds) -- does the loop
//       variable follow the io_decl's ELEMENT typespec or become an array_var?
//   (b) the r10c4 pin, ISOLATED: one task, one `int lq[$]` local, one foreach.
//       t30's `tloc` declares sixteen arrays and golden makes every queue local
//       an array_var, which contradicts the recorded `int lq[$] -> int_var`.
class Cel;
  int x;
endclass

module top;
  task automatic tformal(ref int fq[$], ref int fd[], input int ff[4], ref int fa[string]);
    foreach (fq[i_fq]) fq[i_fq] = fq[i_fq];
    foreach (fd[i_fd]) fd[i_fd] = fd[i_fd];
    foreach (ff[i_ff]) ff[i_ff] = ff[i_ff];
    foreach (fa[i_fa]) fa[i_fa] = fa[i_fa];
  endtask

  task automatic tformalc(ref Cel cq[$], ref Cel ca[string]);
    foreach (cq[i_cq]) cq[i_cq] = cq[i_cq];
    foreach (ca[i_ca]) ca[i_ca] = ca[i_ca];
  endtask

  task tone;
    int lq[$];
    foreach (lq[i]) lq[i] = lq[i];
  endtask

  task ttwo;
    int tq[5];
    foreach (tq[j]) tq[j] = tq[j];
  endtask

  function int fone;
    int rq[$];
    foreach (rq[k]) rq[k] = rq[k];
    return 0;
  endfunction
endmodule
