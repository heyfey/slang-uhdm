// § callResultMemberDropped411
package pk;
  class B;
    int s = 2;
  endclass
  function automatic B mk();
    B o = new;
    return o;
  endfunction
endpackage
module top(output int r);
  initial r = pk::mk().s;
endmodule
