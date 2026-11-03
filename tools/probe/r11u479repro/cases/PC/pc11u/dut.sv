// § parenCallCallee479 (control: the unparenthesized twin of pc11)
class ext;
  extern static function int get(int a);
endclass
function int ext::get(int a); return a; endfunction
module top(output int z);
  initial z = ext::get(3);
endmodule
