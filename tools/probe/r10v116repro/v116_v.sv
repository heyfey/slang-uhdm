// v116 arm V -- PARENTHESISED and otherwise offset receivers of the MEMBER
// form.  If the fence's positional test (arg0 starts where the call starts)
// can be defeated by a leading `(`, this arm shows it.
class holder_v;
  rand int d_v;
  int lim_v;
endclass
class wrap_v;
  holder_v h_arr[2];
  holder_v h_one;
  int mark_v;
  function void go();
    h_one = new();
    if (!(h_one).randomize())
      mark_v = 1;
    if (!(h_one).randomize() with { d_v < 5; })
      mark_v = 2;
    if (!((h_one)).randomize(d_v))
      mark_v = 3;
    if (!h_arr[0].randomize())
      mark_v = 4;
    if (!h_one.randomize())
      mark_v = 5;
  endfunction
endclass
module top_v;
  wrap_v w_one;
  initial begin
    w_one = new();
    w_one.go();
  end
endmodule
