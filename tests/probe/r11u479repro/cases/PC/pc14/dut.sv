// § parenCallCallee479
class obj;
  static function int sf(int a); return a; endfunction
endclass
module top;
  initial $display("%0d", (obj::sf(4)));
endmodule
