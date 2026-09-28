// § classTpKeywordTsAtDefault188
package p;
  class c #(type T = int);
    rand T x;
    constraint cx { x < 10; }
    static T cnt;
    static function T bump(); cnt++; return cnt; endfunction
  endclass
endpackage
module top; endmodule
