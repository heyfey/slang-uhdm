  task automatic mv(input nib_t a, output nib_t b, inout nib_t c, ref nib_t d);
    b = a; c = c ^ a; d = a;
  endtask
  function automatic nib_t cr(const ref nib_t a);
    return a;
  endfunction
