package e03p;
  class K #(parameter KB = 'b101) ;
    static function int g(); return KB; endfunction
  endclass
endpackage
module e03;
  import e03p::*;
  typedef K#(.KB('h2b)) K2;
  initial $display("%0d %0d", K#()::g(), K2::g());
endmodule
