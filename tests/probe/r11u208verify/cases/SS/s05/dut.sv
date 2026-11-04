// § tfSigningSpanFollowsCompilePath200
class k;
  int unsigned prop;
  byte signed bp;
  extern function integer unsigned e1(input time signed t);
  extern static function shortint unsigned e2(input int unsigned a, input byte signed b);
  extern task e3(input longint unsigned l, output bit signed o);
endclass
function integer unsigned k::e1(input time signed t);
  return t;
endfunction
function shortint unsigned k::e2(input int unsigned a, input byte signed b);
  return a + b;
endfunction
task k::e3(input longint unsigned l, output bit signed o);
  o = l[0];
endtask
module s05; k h; endmodule
