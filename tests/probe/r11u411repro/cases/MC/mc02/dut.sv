// § callResultMemberDropped411
module top(output int r);
  class B;
    int s = 2;
  endclass
  function automatic B mk();
    B o = new;
    return o;
  endfunction
  initial r = mk().s;
endmodule
