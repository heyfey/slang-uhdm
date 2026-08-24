// v116 arm T -- std::randomize surface in full: zero args, with-block, under
// a unary !, and assigned; plus a scope randomize in the SAME method so the
// fence must separate them within one compilation.
class mix_t;
  rand int t_one;
  int free_a;
  int free_b;
  int st_t;
  function void go();
    st_t = std::randomize(free_a);
    st_t = std::randomize(free_a, free_b);
    if (!std::randomize(free_b) with { free_b > 1; })
      st_t = 3;
    if (!randomize(t_one) with { t_one < free_a; })
      st_t = 4;
    if (!randomize(t_one))
      st_t = 5;
  endfunction
endclass
module top_t;
  mix_t t_obj;
  initial begin
    t_obj = new();
    t_obj.go();
  end
endmodule
