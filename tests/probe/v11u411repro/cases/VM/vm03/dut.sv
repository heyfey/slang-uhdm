// § callResultMemberDropped411
class B; int s = 2; endclass
function automatic B mk();
  B o = new;
  return o;
endfunction
module top(output int r);
  initial r = mk().s + 1;
endmodule
